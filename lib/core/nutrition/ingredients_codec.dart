import 'dart:convert';

import 'ingredients_models.dart';

/// Parse [ingredientsJson] string without throwing on malformed JSON.
IngredientsParseResult parseIngredientsJson(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return IngredientsParseResult.empty();
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List<dynamic>) {
      return IngredientsParseResult.legacy(legacyListToV2(decoded));
    }
    if (decoded is Map<String, dynamic>) {
      final sv = decoded['schemaVersion'];
      if (sv == IngredientsDocumentV2.currentSchemaVersion) {
        return IngredientsParseResult.version2(_documentV2FromMap(decoded));
      }
      // Map but not v2 — treat as invalid for now (forward-compatible)
      return IngredientsParseResult.invalid('unsupported_object_shape');
    }
    return IngredientsParseResult.invalid('unsupported_top_level_type');
  } catch (e) {
    return IngredientsParseResult.invalid(e.toString());
  }
}

/// Encode v2 document; output contains `schemaVersion` and `mainIngredients`.
String serializeIngredientsV2(IngredientsDocumentV2 doc) {
  return jsonEncode(_documentV2ToMap(doc));
}

/// Convert legacy list (each element = one main) to v2 document.
IngredientsDocumentV2 legacyListToV2(List<dynamic> list) {
  final mains = <IngredientNode>[];
  for (final item in list) {
    if (item is Map<String, dynamic>) {
      mains.add(_nodeFromDynamicMap(item, isRoot: true));
    } else if (item is Map) {
      mains.add(_nodeFromDynamicMap(
          Map<String, dynamic>.from(item),
          isRoot: true));
    }
  }
  return IngredientsDocumentV2(mainIngredients: mains);
}

/// Flatten AI roots so each root becomes one main with at most one level of subs.
///
/// กันซ้ำซ้อนแคลอรี่: เมื่อยุบโหนดกลาง เราไม่เก็บแถวกลางที่มีลูกซ้อน —
/// แจกงบ macro ของแถวกลางให้ลูกที่ hoist ตามสัดส่วนแคลอรี่ของลูก (หรือเท่าๆ กันถ้าไม่มีแคลอรี่)
IngredientsDocumentV2 flattenAiIngredientRoots(List<Map<String, dynamic>> roots) {
  final mains = <IngredientNode>[];
  for (final root in roots) {
    mains.add(_flattenRootToMain(root));
  }
  return IngredientsDocumentV2(mainIngredients: mains);
}

/// Roll up sub → main → entry macros; micro (fiber/sugar/sodium) ตาม D-08b.
EntryNutritionRollup recomputeEntryRollup({
  required IngredientsDocumentV2 doc,
  double? entryFiber,
  double? entrySugar,
  double? entrySodium,
}) {
  double c = 0, p = 0, cb = 0, f = 0;

  for (final main in doc.mainIngredients) {
    final rolled = _rollupMain(main);
    c += rolled.calories;
    p += rolled.protein;
    cb += rolled.carbs;
    f += rolled.fat;
  }

  final micro = _rollupMicroPreserve(
    doc,
    entryFiber: entryFiber,
    entrySugar: entrySugar,
    entrySodium: entrySodium,
  );

  return EntryNutritionRollup(
    calories: c,
    protein: p,
    carbs: cb,
    fat: f,
    fiber: micro.$1,
    sugar: micro.$2,
    sodium: micro.$3,
  );
}

/// Alias for callers that follow ROADMAP wording "recomputeEntryTotals".
EntryNutritionRollup recomputeEntryTotals({
  required IngredientsDocumentV2 doc,
  double? entryFiber,
  double? entrySugar,
  double? entrySodium,
}) =>
    recomputeEntryRollup(
      doc: doc,
      entryFiber: entryFiber,
      entrySugar: entrySugar,
      entrySodium: entrySodium,
    );

// --- internal ---

Map<String, dynamic> _documentV2ToMap(IngredientsDocumentV2 doc) {
  return {
    'schemaVersion': doc.schemaVersion,
    'mainIngredients': doc.mainIngredients.map(_nodeToMap).toList(),
  };
}

IngredientsDocumentV2 _documentV2FromMap(Map<String, dynamic> map) {
  final mainsRaw = map['mainIngredients'];
  final mains = <IngredientNode>[];
  if (mainsRaw is List) {
    for (final m in mainsRaw) {
      if (m is Map<String, dynamic>) {
        mains.add(_nodeFromDynamicMap(m, isRoot: true));
      } else if (m is Map) {
        mains.add(_nodeFromDynamicMap(Map<String, dynamic>.from(m), isRoot: true));
      }
    }
  }
  return IngredientsDocumentV2(
    schemaVersion: (map['schemaVersion'] as num?)?.toInt() ??
        IngredientsDocumentV2.currentSchemaVersion,
    mainIngredients: mains,
  );
}

Map<String, dynamic> _nodeToMap(IngredientNode n) {
  final map = <String, dynamic>{
    'name': n.name,
    'name_en': n.nameEn,
    'amount': n.amount,
    'unit': n.unit,
    'calories': n.calories,
    'protein': n.protein,
    'carbs': n.carbs,
    'fat': n.fat,
  };
  if (n.fiber != null) map['fiber'] = n.fiber;
  if (n.sugar != null) map['sugar'] = n.sugar;
  if (n.sodium != null) map['sodium'] = n.sodium;
  if (n.imagePath != null && n.imagePath!.isNotEmpty) {
    map['imagePath'] = n.imagePath;
  }
  if (n.arBoundingBox != null && n.arBoundingBox!.isNotEmpty) {
    map['arBoundingBox'] = n.arBoundingBox;
  }
  if (n.arImageWidth != null) map['arImageWidth'] = n.arImageWidth;
  if (n.arImageHeight != null) map['arImageHeight'] = n.arImageHeight;
  if (n.subIngredients.isNotEmpty) {
    map['subIngredients'] = n.subIngredients.map(_nodeToMap).toList();
  }
  return map;
}

List<dynamic>? _subListFromMap(Map<String, dynamic> map) {
  final a = map['subIngredients'];
  if (a is List) return a;
  final b = map['sub_ingredients'];
  if (b is List) return b;
  return null;
}

IngredientNode _nodeFromDynamicMap(Map<String, dynamic> map, {required bool isRoot}) {
  final subsRaw = _subListFromMap(map);
  final subs = <IngredientNode>[];
  if (subsRaw != null) {
    for (final s in subsRaw) {
      if (s is Map<String, dynamic>) {
        subs.add(_nodeFromDynamicMap(s, isRoot: false));
      } else if (s is Map) {
        subs.add(_nodeFromDynamicMap(
            Map<String, dynamic>.from(s), isRoot: false));
      }
    }
  }
  return IngredientNode(
    name: (map['name'] as String?)?.trim() ?? '',
    nameEn: map['name_en'] as String?,
    amount: _toDouble(map['amount']),
    unit: (map['unit'] as String?) ?? 'g',
    calories: _toDouble(map['calories']),
    protein: _toDouble(map['protein']),
    carbs: _toDouble(map['carbs']),
    fat: _toDouble(map['fat']),
    fiber: _optionalDouble(map['fiber']),
    sugar: _optionalDouble(map['sugar']),
    sodium: _optionalDouble(map['sodium']),
    subIngredients: subs,
    imagePath: _optionalString(map['imagePath']),
    arBoundingBox: _optionalString(map['arBoundingBox']),
    arImageWidth: _optionalInt(map['arImageWidth']),
    arImageHeight: _optionalInt(map['arImageHeight']),
  );
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

double? _optionalDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

String? _optionalString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int? _optionalInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

IngredientNode _rollupMain(IngredientNode main) {
  if (main.subIngredients.isEmpty) {
    return main;
  }
  double c = 0, p = 0, cb = 0, f = 0;
  for (final s in main.subIngredients) {
    c += s.calories;
    p += s.protein;
    cb += s.carbs;
    f += s.fat;
  }
  return main.copyWith(
    calories: c,
    protein: p,
    carbs: cb,
    fat: f,
    subIngredients: main.subIngredients,
  );
}

/// D-08b: sum micro only if every participating node defines that field; else preserve.
( double?, double?, double?) _rollupMicroPreserve(
  IngredientsDocumentV2 doc, {
  double? entryFiber,
  double? entrySugar,
  double? entrySodium,
}) {
  final nodes = <IngredientNode>[];
  void walk(IngredientNode n) {
    if (n.subIngredients.isEmpty) {
      nodes.add(n);
    } else {
      for (final s in n.subIngredients) {
        walk(s);
      }
    }
  }
  for (final m in doc.mainIngredients) {
    walk(m);
  }

  double? sumIfAll(bool Function(IngredientNode) has,
      double? Function(IngredientNode) get) {
    var ok = true;
    double sum = 0;
    for (final n in nodes) {
      if (!has(n)) {
        ok = false;
        break;
      }
      sum += get(n)!;
    }
    if (!ok || nodes.isEmpty) return null;
    return sum;
  }

  final fiber = sumIfAll((n) => n.fiber != null, (n) => n.fiber);
  final sugar = sumIfAll((n) => n.sugar != null, (n) => n.sugar);
  final sodium = sumIfAll((n) => n.sodium != null, (n) => n.sodium);

  return (
    fiber ?? entryFiber,
    sugar ?? entrySugar,
    sodium ?? entrySodium,
  );
}

IngredientNode _flattenRootToMain(Map<String, dynamic> root) {
  final name = (root['name'] as String?)?.trim() ?? '';
  final nameEn = root['name_en'] as String?;
  final rootUnit = (root['unit'] as String?) ?? 'g';
  final rootAmount = _toDouble(root['amount']);
  final subsRaw = _subListFromMap(root);
  final flatSubs = <IngredientNode>[];
  if (subsRaw != null) {
    for (final item in subsRaw) {
      Map<String, dynamic> m;
      if (item is Map<String, dynamic>) {
        m = item;
      } else if (item is Map) {
        m = Map<String, dynamic>.from(item);
      } else {
        continue;
      }
      flatSubs.addAll(_flattenSubBranch(m, parentLabel: name));
    }
  }
  var c = _toDouble(root['calories']);
  var p = _toDouble(root['protein']);
  var cb = _toDouble(root['carbs']);
  var f = _toDouble(root['fat']);
  if (flatSubs.isNotEmpty) {
    double sumC = 0, sumP = 0, sumCb = 0, sumF = 0;
    for (final s in flatSubs) {
      sumC += s.calories;
      sumP += s.protein;
      sumCb += s.carbs;
      sumF += s.fat;
    }

    // When root's declared calories significantly exceed sum of subs, the root
    // ingredient itself carries "missing" nutrition (e.g. lady-finger cookie
    // 140 kcal with sub coffee 2 kcal — the cookie base is 138 kcal).
    // Insert a self sub-ingredient at position 0 so no calories are lost.
    final deltaC = c - sumC;
    if (deltaC > 1) {
      double selfAmount = rootAmount;
      for (final s in flatSubs) {
        if (s.unit == rootUnit) selfAmount -= s.amount;
      }
      if (selfAmount <= 0) selfAmount = rootAmount;

      flatSubs.insert(
        0,
        IngredientNode(
          name: name,
          nameEn: nameEn,
          amount: selfAmount,
          unit: rootUnit,
          calories: deltaC,
          protein: (p - sumP).clamp(0.0, double.infinity),
          carbs: (cb - sumCb).clamp(0.0, double.infinity),
          fat: (f - sumF).clamp(0.0, double.infinity),
        ),
      );
    }

    c = 0;
    p = 0;
    cb = 0;
    f = 0;
    for (final s in flatSubs) {
      c += s.calories;
      p += s.protein;
      cb += s.carbs;
      f += s.fat;
    }
  }
  return IngredientNode(
    name: name,
    nameEn: nameEn,
    amount: rootAmount,
    unit: rootUnit,
    calories: c,
    protein: p,
    carbs: cb,
    fat: f,
    fiber: _optionalDouble(root['fiber']),
    sugar: _optionalDouble(root['sugar']),
    sodium: _optionalDouble(root['sodium']),
    subIngredients: flatSubs,
    imagePath: _optionalString(root['imagePath']),
    arBoundingBox: _optionalString(root['arBoundingBox']),
    arImageWidth: _optionalInt(root['arImageWidth']),
    arImageHeight: _optionalInt(root['arImageHeight']),
  );
}

/// If [node] has nested subs, hoist grandchildren as direct subs of the root main
/// (caller merges lists). Otherwise return a single leaf node.
List<IngredientNode> _flattenSubBranch(
  Map<String, dynamic> node, {
  required String parentLabel,
}) {
  final nested = _subListFromMap(node);
  final nodeName = (node['name'] as String?)?.trim() ?? '';
  final label = parentLabel.isEmpty ? nodeName : '$parentLabel › $nodeName';

  if (nested == null || nested.isEmpty) {
    return [
      _leafFromMap(node, displayName: nodeName.isEmpty ? label : nodeName),
    ];
  }

  // Allocate this node's macro budget across hoisted children.
  final parentC = _toDouble(node['calories']);
  final parentP = _toDouble(node['protein']);
  final parentCb = _toDouble(node['carbs']);
  final parentF = _toDouble(node['fat']);

  final children = <Map<String, dynamic>>[];
  for (final c in nested) {
    if (c is Map<String, dynamic>) {
      children.add(c);
    } else if (c is Map) {
      children.add(Map<String, dynamic>.from(c));
    }
  }

  double sumChildCal = 0;
  for (final c in children) {
    sumChildCal += _toDouble(c['calories']);
  }

  final out = <IngredientNode>[];
  final n = children.length;
  for (var i = 0; i < n; i++) {
    final c = children[i];
    final ratio = sumChildCal > 0
        ? (_toDouble(c['calories']) / sumChildCal)
        : (n > 0 ? 1.0 / n : 0.0);
    final grand = _subListFromMap(c);
    if (grand == null || grand.isEmpty) {
      out.add(
        _leafFromMap(
          c,
          displayName: '$label › ${(c['name'] as String?)?.trim() ?? ''}',
          scaleCalories: parentC * ratio,
          scaleProtein: parentP * ratio,
          scaleCarbs: parentCb * ratio,
          scaleFat: parentF * ratio,
        ),
      );
    } else {
      // Deeper nesting: recurse — pass combined label.
      final subName = (c['name'] as String?)?.trim() ?? '';
      final nextLabel = '$label › $subName'.trim();
      final deeper = <IngredientNode>[];
      for (final g in grand) {
        Map<String, dynamic> gm;
        if (g is Map<String, dynamic>) {
          gm = g;
        } else if (g is Map) {
          gm = Map<String, dynamic>.from(g);
        } else {
          continue;
        }
        deeper.addAll(_flattenSubBranch(gm, parentLabel: nextLabel));
      }
      // Redistribute parent budget across deeper flat list by their own calories.
      double sumD = 0;
      for (final d in deeper) {
        sumD += d.calories;
      }
      final m = deeper.length;
      for (var j = 0; j < m; j++) {
        final d = deeper[j];
        final r = sumD > 0 ? d.calories / sumD : (m > 0 ? 1.0 / m : 0.0);
        out.add(
          d.copyWith(
            calories: parentC * ratio * r,
            protein: parentP * ratio * r,
            carbs: parentCb * ratio * r,
            fat: parentF * ratio * r,
          ),
        );
      }
    }
  }
  return out;
}

IngredientNode _leafFromMap(
  Map<String, dynamic> map, {
  required String displayName,
  double? scaleCalories,
  double? scaleProtein,
  double? scaleCarbs,
  double? scaleFat,
}) {
  return IngredientNode(
    name: displayName,
    nameEn: map['name_en'] as String?,
    amount: _toDouble(map['amount']),
    unit: (map['unit'] as String?) ?? 'g',
    calories: scaleCalories ?? _toDouble(map['calories']),
    protein: scaleProtein ?? _toDouble(map['protein']),
    carbs: scaleCarbs ?? _toDouble(map['carbs']),
    fat: scaleFat ?? _toDouble(map['fat']),
    fiber: _optionalDouble(map['fiber']),
    sugar: _optionalDouble(map['sugar']),
    sodium: _optionalDouble(map['sodium']),
    subIngredients: const [],
    imagePath: _optionalString(map['imagePath']),
    arBoundingBox: _optionalString(map['arBoundingBox']),
    arImageWidth: _optionalInt(map['arImageWidth']),
    arImageHeight: _optionalInt(map['arImageHeight']),
  );
}
