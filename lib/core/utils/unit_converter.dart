/// Centralized unit system for the entire app.
/// - Defines all available serving units (grouped by category)
/// - Provides conversion between compatible units (weight↔weight, volume↔volume)
/// - Supplies dropdown items for all screens (single source of truth)
///
/// Usage:
///   UnitConverter.convert(200, from: 'g', to: 'lbs') → 0.4409
///   UnitConverter.canConvert('g', 'lbs') → true
///   UnitConverter.canConvert('g', 'piece') → false
///   UnitConverter.allDropdownUnits → full list for DropdownButtonFormField
///   UnitConverter.compactDropdownUnits → short list for ingredient rows
library;

import 'package:flutter/material.dart';

// ============================================================
// Unit categories
// ============================================================

enum UnitCategory {
  weight, // g, kg, mg, oz, lbs, etc.
  volume, // ml, l, fl oz, cup, tbsp, tsp
  count, // piece, slice, egg, ball, serving, etc.
  package, // bag, box, can, bottle, etc.
}

// ============================================================
// Unit definition
// ============================================================

class ServingUnit {
  final String key; // unique id stored in DB  e.g. 'g', 'lbs'
  final String label; // display in dropdown     e.g. 'g (gram)'
  final String shortLabel; // compact display         e.g. 'g'
  final UnitCategory category;

  /// Factor to convert TO the base unit of its category.
  /// Weight  → base = grams   (1 kg = 1000 g  → factor=1000)
  /// Volume  → base = ml      (1 cup = 236.588 ml → factor=236.588)
  /// Count / Package → factor = 1 (not convertible across units)
  final double toBaseFactor;

  const ServingUnit({
    required this.key,
    required this.label,
    required this.shortLabel,
    required this.category,
    this.toBaseFactor = 1,
  });
}

// ============================================================
// Master unit list  (ORDER = dropdown order)
// ============================================================

class UnitConverter {
  UnitConverter._();

  // ---------- Weight (base = gram) ----------
  static const _weight = [
    ServingUnit(
        key: 'g',
        label: 'gram (g)',
        shortLabel: 'g',
        category: UnitCategory.weight,
        toBaseFactor: 1),
    ServingUnit(
        key: 'kg',
        label: 'kilogram (kg)',
        shortLabel: 'kg',
        category: UnitCategory.weight,
        toBaseFactor: 1000),
    ServingUnit(
        key: 'mg',
        label: 'milligram (mg)',
        shortLabel: 'mg',
        category: UnitCategory.weight,
        toBaseFactor: 0.001),
    ServingUnit(
        key: 'oz',
        label: 'ounce (oz)',
        shortLabel: 'oz',
        category: UnitCategory.weight,
        toBaseFactor: 28.3495),
    ServingUnit(
        key: 'lbs',
        label: 'pound (lbs)',
        shortLabel: 'lbs',
        category: UnitCategory.weight,
        toBaseFactor: 453.592),
  ];

  // ---------- Volume (base = ml) ----------
  static const _volume = [
    ServingUnit(
        key: 'ml',
        label: 'milliliter (ml)',
        shortLabel: 'ml',
        category: UnitCategory.volume,
        toBaseFactor: 1),
    ServingUnit(
        key: 'l',
        label: 'liter (l)',
        shortLabel: 'l',
        category: UnitCategory.volume,
        toBaseFactor: 1000),
    ServingUnit(
        key: 'fl oz',
        label: 'fluid ounce (fl oz)',
        shortLabel: 'fl oz',
        category: UnitCategory.volume,
        toBaseFactor: 29.5735),
    ServingUnit(
        key: 'cup',
        label: 'cup',
        shortLabel: 'cup',
        category: UnitCategory.volume,
        toBaseFactor: 236.588),
    ServingUnit(
        key: 'tbsp',
        label: 'tablespoon (tbsp)',
        shortLabel: 'tbsp',
        category: UnitCategory.volume,
        toBaseFactor: 15),
    ServingUnit(
        key: 'tsp',
        label: 'teaspoon (tsp)',
        shortLabel: 'tsp',
        category: UnitCategory.volume,
        toBaseFactor: 5),
  ];

  // ---------- Count / Portion ----------
  static const _count = [
    ServingUnit(
        key: 'serving',
        label: 'serving',
        shortLabel: 'srv',
        category: UnitCategory.count),
    ServingUnit(
        key: 'piece',
        label: 'piece',
        shortLabel: 'pc',
        category: UnitCategory.count),
    ServingUnit(
        key: 'slice',
        label: 'slice',
        shortLabel: 'slice',
        category: UnitCategory.count),
    ServingUnit(
        key: 'plate',
        label: 'plate',
        shortLabel: 'plate',
        category: UnitCategory.count),
    ServingUnit(
        key: 'bowl',
        label: 'bowl',
        shortLabel: 'bowl',
        category: UnitCategory.count),
    ServingUnit(
        key: 'cup_c',
        label: 'cup (count)',
        shortLabel: 'cup',
        category: UnitCategory.count),
    ServingUnit(
        key: 'glass',
        label: 'glass',
        shortLabel: 'glass',
        category: UnitCategory.count),
    ServingUnit(
        key: 'egg',
        label: 'egg',
        shortLabel: 'egg',
        category: UnitCategory.count),
    ServingUnit(
        key: 'ball',
        label: 'ball',
        shortLabel: 'ball',
        category: UnitCategory.count),
    ServingUnit(
        key: 'fruit',
        label: 'fruit',
        shortLabel: 'fruit',
        category: UnitCategory.count),
    ServingUnit(
        key: 'skewer',
        label: 'skewer',
        shortLabel: 'skw',
        category: UnitCategory.count),
    ServingUnit(
        key: 'whole',
        label: 'whole',
        shortLabel: 'whole',
        category: UnitCategory.count),
    ServingUnit(
        key: 'sheet',
        label: 'sheet',
        shortLabel: 'sht',
        category: UnitCategory.count),
    ServingUnit(
        key: 'pair',
        label: 'pair',
        shortLabel: 'pair',
        category: UnitCategory.count),
    ServingUnit(
        key: 'bunch',
        label: 'bunch',
        shortLabel: 'bnch',
        category: UnitCategory.count),
    ServingUnit(
        key: 'leaf',
        label: 'leaf',
        shortLabel: 'leaf',
        category: UnitCategory.count),
    ServingUnit(
        key: 'stick',
        label: 'stick',
        shortLabel: 'stk',
        category: UnitCategory.count),
    ServingUnit(
        key: 'scoop',
        label: 'scoop',
        shortLabel: 'scoop',
        category: UnitCategory.count),
    ServingUnit(
        key: 'handful',
        label: 'handful',
        shortLabel: 'hndfl',
        category: UnitCategory.count),
  ];

  // ---------- Package ----------
  static const _package = [
    ServingUnit(
        key: 'pack',
        label: 'pack',
        shortLabel: 'pack',
        category: UnitCategory.package),
    ServingUnit(
        key: 'bag',
        label: 'bag',
        shortLabel: 'bag',
        category: UnitCategory.package),
    ServingUnit(
        key: 'wrap',
        label: 'wrap',
        shortLabel: 'wrap',
        category: UnitCategory.package),
    ServingUnit(
        key: 'box',
        label: 'box',
        shortLabel: 'box',
        category: UnitCategory.package),
    ServingUnit(
        key: 'can',
        label: 'can',
        shortLabel: 'can',
        category: UnitCategory.package),
    ServingUnit(
        key: 'bottle',
        label: 'bottle',
        shortLabel: 'btl',
        category: UnitCategory.package),
    ServingUnit(
        key: 'bar',
        label: 'bar',
        shortLabel: 'bar',
        category: UnitCategory.package),
  ];

  // ---------- ALL units (ordered) ----------
  static List<ServingUnit> get allUnits => [
        ..._weight,
        ..._volume,
        ..._count,
        ..._package,
      ];

  // ---------- Lookup map (lazy) ----------
  static final Map<String, ServingUnit> _map = {
    for (final u in allUnits) u.key: u,
  };

  /// Legacy Thai key → new English key mapping
  static final Map<String, String> _legacyMap = {
    'จาน': 'plate', 'ถ้วย': 'bowl', 'ชาม': 'bowl',
    'ชิ้น': 'piece', 'ฟอง': 'egg', 'ลูก': 'ball',
    'ผล': 'fruit', 'แก้ว': 'glass', 'ไม้': 'skewer',
    'ตัว': 'whole', 'แผ่น': 'sheet', 'คู่': 'pair',
    'มัด': 'bunch', 'หัว': 'whole', 'ใบ': 'leaf',
    'ซอง': 'pack', 'ถุง': 'bag', 'ห่อ': 'wrap',
    'กล่อง': 'box', 'กระป๋อง': 'can', 'ขวด': 'bottle',
    'ช้อนโต๊ะ': 'tbsp', 'ช้อนชา': 'tsp',
    'ขีด': 'g', // 1 ขีด = 100g → handled specially
    'หน่วยบริโภค': 'serving',
  };

  // ============================================================
  // Public API
  // ============================================================

  /// Look up a unit by key. Also resolves legacy Thai keys.
  static ServingUnit? find(String key) {
    return _map[key] ?? _map[_legacyMap[key]];
  }

  /// Resolve a key (possibly Thai legacy) to the standard English key.
  static String resolveKey(String key) {
    if (_map.containsKey(key)) return key;
    return _legacyMap[key] ?? key;
  }

  /// Whether two units can be converted to each other
  /// (same category AND category is weight or volume).
  static bool canConvert(String fromKey, String toKey) {
    final from = find(fromKey);
    final to = find(toKey);
    if (from == null || to == null) return false;
    if (from.category != to.category) return false;
    return from.category == UnitCategory.weight ||
        from.category == UnitCategory.volume;
  }

  /// Convert a quantity from one unit to another.
  /// Returns null if units are incompatible.
  ///
  /// Example: convert(200, from: 'g', to: 'lbs') → 0.4409
  static double? convert(double quantity,
      {required String from, required String to}) {
    final fromUnit = find(from);
    final toUnit = find(to);
    if (fromUnit == null || toUnit == null) return null;
    if (fromUnit.category != toUnit.category) return null;
    if (fromUnit.category != UnitCategory.weight &&
        fromUnit.category != UnitCategory.volume) {
      return null;
    }

    // quantity → base → target
    final inBase = quantity * fromUnit.toBaseFactor;
    return inBase / toUnit.toBaseFactor;
  }

  /// Given nutrition for [oldQty] of [oldUnit],
  /// returns (newQty, newNutritionMultiplier) when switching to [newUnit].
  ///
  /// If convertible: qty changes, nutrition stays the same (multiplier=1).
  /// If not convertible: qty stays, nutrition recalculates from base per unit.
  static ({double newQty, bool converted}) convertServing({
    required double oldQty,
    required String oldUnit,
    required String newUnit,
  }) {
    final converted = convert(oldQty, from: oldUnit, to: newUnit);
    if (converted != null) {
      return (newQty: converted, converted: true);
    }
    // Not convertible — keep quantity, caller must recalculate nutrition
    return (newQty: oldQty, converted: false);
  }

  // ============================================================
  // Dropdown helpers
  // ============================================================

  /// Full dropdown items for main forms (AddFood, EditFood, FoodPreview)
  static List<DropdownMenuItem<String>> get allDropdownItems => [
        // --- Standard measurement (top) ---
        const DropdownMenuItem(
            value: '',
            enabled: false,
            child: Text('─── Weight ───',
                style: TextStyle(fontSize: 12, color: Colors.grey))),
        ..._weight
            .map((u) => DropdownMenuItem(value: u.key, child: Text(u.label))),

        const DropdownMenuItem(
            value: '',
            enabled: false,
            child: Text('─── Volume ───',
                style: TextStyle(fontSize: 12, color: Colors.grey))),
        ..._volume
            .map((u) => DropdownMenuItem(value: u.key, child: Text(u.label))),

        const DropdownMenuItem(
            value: '',
            enabled: false,
            child: Text('─── Count / Portion ───',
                style: TextStyle(fontSize: 12, color: Colors.grey))),
        ..._count
            .map((u) => DropdownMenuItem(value: u.key, child: Text(u.label))),

        const DropdownMenuItem(
            value: '',
            enabled: false,
            child: Text('─── Package ───',
                style: TextStyle(fontSize: 12, color: Colors.grey))),
        ..._package
            .map((u) => DropdownMenuItem(value: u.key, child: Text(u.label))),
      ];

  /// Selectable-only items (no separators) — for validation
  static List<String> get allUnitKeys => allUnits.map((u) => u.key).toList();

  /// Compact dropdown for ingredient rows (shorter labels)
  static List<DropdownMenuItem<String>> get compactDropdownItems => [
        ..._weight.map(
            (u) => DropdownMenuItem(value: u.key, child: Text(u.shortLabel))),
        ..._volume.map(
            (u) => DropdownMenuItem(value: u.key, child: Text(u.shortLabel))),
        ..._count.map(
            (u) => DropdownMenuItem(value: u.key, child: Text(u.shortLabel))),
        ..._package.map(
            (u) => DropdownMenuItem(value: u.key, child: Text(u.shortLabel))),
      ];

  /// Ensure a unit key is valid (in our list). If not, return 'serving'.
  static String ensureValid(String? key) {
    if (key == null || key.isEmpty) return 'serving';
    if (_map.containsKey(key)) return key;
    // Try legacy
    final resolved = _legacyMap[key];
    if (resolved != null && _map.containsKey(resolved)) return resolved;
    return 'serving';
  }

  /// Get display label for a unit key.
  static String displayLabel(String key) => find(key)?.label ?? key;

  /// Get short label for a unit key.
  static String shortLabel(String key) => find(key)?.shortLabel ?? key;

  // ============================================================
  // Locale-aware display names
  // ============================================================

  /// ชื่อหน่วยที่แสดงให้ผู้ใช้เห็น — ตาม locale
  static final Map<String, Map<String, String>> _unitDisplayNames = {
    'g': {'th': 'กรัม', 'en': 'g'},
    'kg': {'th': 'กก.', 'en': 'kg'},
    'mg': {'th': 'มก.', 'en': 'mg'},
    'lbs': {'th': 'ปอนด์', 'en': 'lbs'},
    'oz': {'th': 'ออนซ์', 'en': 'oz'},
    'ml': {'th': 'มล.', 'en': 'ml'},
    'l': {'th': 'ลิตร', 'en': 'L'},
    'fl oz': {'th': 'ฟลูอิดออนซ์', 'en': 'fl oz'},
    'cup': {'th': 'ถ้วย', 'en': 'cup'},
    'tbsp': {'th': 'ช้อนโต๊ะ', 'en': 'tbsp'},
    'tsp': {'th': 'ช้อนชา', 'en': 'tsp'},
    'serving': {'th': 'เสิร์ฟ', 'en': 'serving'},
    'piece': {'th': 'ชิ้น', 'en': 'piece'},
    'slice': {'th': 'ชิ้น', 'en': 'slice'},
    'plate': {'th': 'จาน', 'en': 'plate'},
    'bowl': {'th': 'ชาม', 'en': 'bowl'},
    'cup_c': {'th': 'ถ้วย', 'en': 'cup'},
    'glass': {'th': 'แก้ว', 'en': 'glass'},
    'egg': {'th': 'ฟอง', 'en': 'egg'},
    'ball': {'th': 'ลูก', 'en': 'ball'},
    'fruit': {'th': 'ผล', 'en': 'fruit'},
    'skewer': {'th': 'ไม้', 'en': 'skewer'},
    'whole': {'th': 'ตัว', 'en': 'whole'},
    'sheet': {'th': 'แผ่น', 'en': 'sheet'},
    'pair': {'th': 'คู่', 'en': 'pair'},
    'bunch': {'th': 'มัด', 'en': 'bunch'},
    'leaf': {'th': 'ใบ', 'en': 'leaf'},
    'stick': {'th': 'ไม้', 'en': 'stick'},
    'scoop': {'th': 'สคูป', 'en': 'scoop'},
    'handful': {'th': 'กำมือ', 'en': 'handful'},
    'pack': {'th': 'ห่อ', 'en': 'pack'},
    'bag': {'th': 'ถุง', 'en': 'bag'},
    'wrap': {'th': 'ห่อ', 'en': 'wrap'},
    'box': {'th': 'กล่อง', 'en': 'box'},
    'can': {'th': 'กระป๋อง', 'en': 'can'},
    'bottle': {'th': 'ขวด', 'en': 'bottle'},
    'bar': {'th': 'แท่ง', 'en': 'bar'},
  };

  /// แสดงชื่อหน่วย ตาม locale
  static String displayUnit(String unitKey, String locale) {
    final names = _unitDisplayNames[unitKey];
    if (names == null) {
      return displayLabel(unitKey); // fallback to original label
    }
    return names[locale] ?? names['en'] ?? unitKey;
  }

  /// Dropdown items — แสดงตาม locale
  static List<DropdownMenuItem<String>> dropdownItems(String locale) {
    return allUnits.map((unit) {
      return DropdownMenuItem(
        value: unit.key,
        child: Text(displayUnit(unit.key, locale)),
      );
    }).toList();
  }
}
