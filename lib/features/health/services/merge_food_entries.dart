import 'dart:ui' show Size;

import 'package:miro_hybrid/core/ar_scale/models/detected_object_label.dart';
import 'package:miro_hybrid/core/database/app_database.dart';
import 'package:miro_hybrid/core/database/model_extensions.dart';
import 'package:miro_hybrid/core/nutrition/ingredients_codec.dart';
import 'package:miro_hybrid/core/nutrition/ingredients_models.dart';

/// ชื่อถัดไปเป็น `group1`, `group2`, … จากรายการชื่อที่มีแล้วที่ตรงรูปแบบ `group` + ตัวเลขเท่านั้น
String computeNextSequentialGroupName(Iterable<String> existingFoodNames) {
  final re = RegExp(r'^group(\d+)$', caseSensitive: false);
  var max = 0;
  for (final raw in existingFoodNames) {
    final m = re.firstMatch(raw.trim());
    if (m != null) {
      final n = int.tryParse(m.group(1)!) ?? 0;
      if (n > max) max = n;
    }
  }
  return 'group${max + 1}';
}

/// Result of merging multiple [FoodEntry] rows into one grouped entry (ingredients v2).
class MergeFoodEntriesResult {
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String ingredientsJson;
  /// ลำดับ path รูปทั้งหมด (ไม่จำกัดจำนวน) — บันทึกลง DB ผ่าน 3 คอลัมน์ + [FoodEntryData.imagePathsJson] เมื่อ >3
  final List<String> mergedImagePaths;
  final String? arLabelsJson;
  final double? arImageWidth;
  final double? arImageHeight;
  final MealType mealType;
  final DateTime timestamp;

  const MergeFoodEntriesResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredientsJson,
    required this.mergedImagePaths,
    this.arLabelsJson,
    this.arImageWidth,
    this.arImageHeight,
    required this.mealType,
    required this.timestamp,
  });
}

/// Flattens nested sub-ingredients to a single level (no sub-sub) for v2 storage.
IngredientNode _flattenMainSubsForMerge(IngredientNode main) {
  if (main.subIngredients.isEmpty) return main;
  final flat = <IngredientNode>[];
  for (final s in main.subIngredients) {
    flat.addAll(_flattenSubToLeaves(s));
  }
  return main.copyWith(subIngredients: flat);
}

List<IngredientNode> _flattenSubToLeaves(IngredientNode n) {
  if (n.subIngredients.isEmpty) return [n];
  final out = <IngredientNode>[];
  for (final c in n.subIngredients) {
    out.addAll(_flattenSubToLeaves(c));
  }
  return out;
}

List<IngredientNode> _mainsFromEntry(FoodEntry e) {
  final parsed = parseIngredientsJson(e.ingredientsJson);
  final doc = parsed.documentV2;
  if (doc != null && doc.mainIngredients.isNotEmpty) {
    return doc.mainIngredients.map(_flattenMainSubsForMerge).toList();
  }
  final name = e.foodName.trim().isEmpty ? '—' : e.foodName.trim();
  return [
    IngredientNode(
      name: name,
      amount: e.servingSize,
      unit: e.servingUnit,
      calories: e.calories,
      protein: e.protein,
      carbs: e.carbs,
      fat: e.fat,
    ),
  ];
}

/// Unique paths in chronological order (ไม่จำกัดจำนวน).
List<String> _collectMergedImagePaths(List<FoodEntry> sorted) {
  final seen = <String>{};
  final out = <String>[];
  for (final e in sorted) {
    for (final p in e.allImagePaths) {
      final t = p.trim();
      if (t.isEmpty) continue;
      if (seen.add(t)) {
        out.add(t);
      }
    }
  }
  return out;
}

/// Build multi-image `arLabelsJson` aligned with [mergedPaths] indices.
String? _mergeArLabelsForPaths(List<FoodEntry> sorted, List<String> mergedPaths) {
  final built = <ArImageDetectionData>[];
  for (var newIdx = 0; newIdx < mergedPaths.length; newIdx++) {
    final p = mergedPaths[newIdx];
    ArImageDetectionData? chosen;
    for (final e in sorted) {
      final localPaths = e.allImagePaths;
      final localIdx = localPaths.indexWhere((x) => x == p);
      if (localIdx < 0) continue;

      final labels =
          ArImageDetectionData.labelsForImage(e.arLabelsJson, localIdx);
      Size? sz = ArImageDetectionData.imageSizeForImage(e.arLabelsJson, localIdx);
      var w = sz?.width ?? 0.0;
      var h = sz?.height ?? 0.0;
      if (w <= 0 || h <= 0) {
        w = (e.arImageWidth ?? 0).toDouble();
        h = (e.arImageHeight ?? 0).toDouble();
      }
      if (labels.isEmpty) break;

      if (w > 0 && h > 0) {
        chosen = ArImageDetectionData(
          imageIndex: newIdx,
          imageWidth: w,
          imageHeight: h,
          pixelPerCm: e.arPixelPerCm,
          labels: labels,
        );
      } else {
        chosen = ArImageDetectionData(
          imageIndex: newIdx,
          imageWidth: 1,
          imageHeight: 1,
          pixelPerCm: e.arPixelPerCm,
          labels: labels,
        );
      }
      break;
    }
    if (chosen != null) built.add(chosen);
  }
  if (built.isEmpty) return null;
  return ArImageDetectionData.encodeMultiImage(built);
}

(FoodEntry?, int) _entryAndLocalIndexForPath(List<FoodEntry> sorted, String path) {
  for (final e in sorted) {
    final localPaths = e.allImagePaths;
    final localIdx = localPaths.indexWhere((x) => x == path);
    if (localIdx >= 0) return (e, localIdx);
  }
  return (null, -1);
}

/// Builds one logical [FoodEntry] payload from ≥2 entries (sorted oldest-first).
///
/// The new [FoodEntry] must use [FoodEntry.isGroupOriginal] == true (caller).
/// [groupFoodName] ชื่อที่จะแสดง (เช่น จาก [computeNextSequentialGroupName]).
MergeFoodEntriesResult buildMergedEntry(
  List<FoodEntry> entries, {
  required String groupFoodName,
}) {
  if (entries.length < 2) {
    throw ArgumentError.value(entries.length, 'entries.length', 'need >= 2');
  }

  final sorted = List<FoodEntry>.from(entries)
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final earliest = sorted.first;
  final allMains = <IngredientNode>[];
  for (final e in sorted) {
    allMains.addAll(_mainsFromEntry(e));
  }

  final doc = IngredientsDocumentV2(mainIngredients: allMains);
  final json = serializeIngredientsV2(doc);

  var cal = 0.0, p = 0.0, cb = 0.0, f = 0.0;
  for (final e in sorted) {
    cal += e.calories;
    p += e.protein;
    cb += e.carbs;
    f += e.fat;
  }

  final paths = _collectMergedImagePaths(sorted);
  final arJson = paths.isEmpty ? null : _mergeArLabelsForPaths(sorted, paths);

  double? arW;
  double? arH;
  if (paths.isNotEmpty) {
    final first = paths.first;
    final (src, localIdx) = _entryAndLocalIndexForPath(sorted, first);
    if (src != null) {
      final sz = ArImageDetectionData.imageSizeForImage(src.arLabelsJson, localIdx);
      if (sz != null && sz.width > 0 && sz.height > 0) {
        arW = sz.width;
        arH = sz.height;
      } else if (src.arImageWidth != null &&
          src.arImageHeight != null &&
          src.arImageWidth! > 0 &&
          src.arImageHeight! > 0) {
        arW = src.arImageWidth;
        arH = src.arImageHeight;
      }
    }
  }

  return MergeFoodEntriesResult(
    foodName: groupFoodName,
    calories: cal,
    protein: p,
    carbs: cb,
    fat: f,
    ingredientsJson: json,
    mergedImagePaths: paths,
    arLabelsJson: arJson,
    arImageWidth: arW,
    arImageHeight: arH,
    mealType: earliest.mealType,
    timestamp: earliest.timestamp,
  );
}
