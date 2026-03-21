#!/usr/bin/env python3
"""
Isar to Drift Migration Script
Automatically converts Isar query syntax to Drift syntax
"""

import re
import sys
from pathlib import Path

# Mapping of collections
COLLECTIONS = {
    'foodEntries': 'foodEntries',
    'foodEntrys': 'foodEntries',  # Isar typo fix
    'ingredients': 'ingredients',
    'myMeals': 'myMeals',
    'myMealIngredients': 'myMealIngredients',
    'chatMessages': 'chatMessages',
    'chatSessions': 'chatSessions',
    'userProfiles': 'userProfiles',
    'dailySummaries': 'dailySummaries',
    'dailySummarys': 'dailySummaries',  # Isar typo fix
    'energyTransactions': 'energyTransactions',
}

def convert_imports(content):
    """Convert imports from Isar to Drift"""
    # Remove Isar imports
    content = re.sub(r"import 'package:isar/isar\.dart';?\s*\n", '', content)
    
    # Add Drift imports if not present
    if 'package:drift/drift.dart' not in content:
        # Find first import line and add Drift import after it
        first_import = re.search(r"^import .*?;\s*$", content, re.MULTILINE)
        if first_import:
            insert_pos = first_import.end()
            drift_import = "\nimport 'package:drift/drift.dart' hide JsonKey;"
            db_import = "\nimport '../../../core/database/app_database.dart';"
            service_import = "\nimport '../../../core/database/database_service.dart';"
            content = content[:insert_pos] + drift_import + db_import + service_import + content[insert_pos:]
    
    # Remove old model imports
    content = re.sub(r"import.*?/models/(food_entry|ingredient|my_meal|my_meal_ingredient|chat_message|user_profile|daily_summary|energy_transaction)\.dart';\s*\n", '', content)
    
    return content

def convert_simple_where_findall(content, collection):
    """Convert: .where().findAll() → db.select().get()"""
    pattern = rf'DatabaseService\.{collection}\s*\.where\(\)\s*\.findAll\(\)'
    replacement = f'DatabaseService.db.select(DatabaseService.db.{collection}).get()'
    return re.sub(pattern, replacement, content)

def convert_simple_where_sort_findall(content, collection):
    """Convert: .where().sortByXxx().findAll() → db.select()..orderBy().get()"""
    # sortByCreatedAt, sortByTimestampDesc, etc.
    pattern = rf'DatabaseService\.{collection}\s*\.where\(\)\s*\.sortBy(\w+?)(Desc)?\(\)\s*\.findAll\(\)'
    
    def replace_func(match):
        field = match.group(1)
        is_desc = match.group(2) == 'Desc'
        
        # Convert camelCase to snake_case field name
        field_snake = re.sub(r'(?<!^)(?=[A-Z])', '_', field).lower()
        
        order = 'desc' if is_desc else 'asc'
        return f'(DatabaseService.db.select(DatabaseService.db.{collection})..orderBy([(tbl) => OrderingTerm.{order}(tbl.{field_snake})])).get()'
    
    return re.sub(pattern, replace_func, content)

def convert_filter_equals_findall(content, collection):
    """Convert: .filter().xxxEqualTo(val).findAll() → .where((tbl) => tbl.xxx.equals(val)).get()"""
    pattern = rf'DatabaseService\.{collection}\s*\.filter\(\)\s*\.(\w+?)EqualTo\(([^)]+)\)\s*\.findAll\(\)'
    
    def replace_func(match):
        field = match.group(1)
        value = match.group(2)
        
        # Convert camelCase to snake_case
        field_snake = re.sub(r'(?<!^)(?=[A-Z])', '_', field).lower()
        
        return f'(DatabaseService.db.select(DatabaseService.db.{collection})..where((tbl) => tbl.{field_snake}.equals({value}))).get()'
    
    return re.sub(pattern, replace_func, content)

def convert_writeTxn(content):
    """Convert: DatabaseService.isar.writeTxn() → DatabaseService.db.transaction()"""
    content = re.sub(r'DatabaseService\.isar\.writeTxn\(\s*\(\)\s*async\s*\{',
                     'DatabaseService.db.transaction(() async {', content)
    return content

def convert_put_single(content, collection):
    """Convert: .put(object) → db.into().insertOnConflictUpdate()"""
    # This is complex - just mark it for manual review
    pattern = rf'await\s+DatabaseService\.{collection}\.put\((\w+)\)'
    
    def replace_func(match):
        var_name = match.group(1)
        return f'// TODO: Convert {var_name} to Companion and use insertOnConflictUpdate\nawait DatabaseService.db.into(DatabaseService.db.{collection}).insertOnConflictUpdate({var_name}Companion)'
    
    return re.sub(pattern, replace_func, content)

def convert_get_by_id(content, collection):
    """Convert: .get(id) → select().where(id.equals()).getSingleOrNull()"""
    pattern = rf'DatabaseService\.{collection}\.get\(([^)]+)\)'
    replacement = rf'(DatabaseService.db.select(DatabaseService.db.{collection})..where((tbl) => tbl.id.equals(\1))).getSingleOrNull()'
    return re.sub(pattern, replacement, content)

def convert_file(filepath):
    """Convert a single Dart file"""
    print(f"Converting {filepath}...")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Apply conversions
    content = convert_imports(content)
    content = convert_writeTxn(content)
    
    for collection in COLLECTIONS.values():
        content = convert_simple_where_findall(content, collection)
        content = convert_simple_where_sort_findall(content, collection)
        content = convert_filter_equals_findall(content, collection)
        content = convert_get_by_id(content, collection)
        content = convert_put_single(content, collection)
    
    if content != original_content:
        # Backup original
        backup_path = filepath.with_suffix('.dart.bak')
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(original_content)
        print(f"  ✓ Backed up to {backup_path}")
        
        # Write converted
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✓ Converted")
        return True
    else:
        print(f"  - No changes")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: python migrate_isar_to_drift.py <path_to_lib_folder>")
        sys.exit(1)
    
    lib_path = Path(sys.argv[1])
    if not lib_path.exists():
        print(f"Error: {lib_path} not found")
        sys.exit(1)
    
    # Find all Dart files
    dart_files = list(lib_path.rglob('*.dart'))
    print(f"Found {len(dart_files)} Dart files")
    
    converted_count = 0
    for dart_file in dart_files:
        # Skip generated files
        if dart_file.suffix == '.g.dart' or dart_file.suffix == '.freezed.dart':
            continue
        
        if convert_file(dart_file):
            converted_count += 1
    
    print(f"\nDone! Converted {converted_count} files")
    print("\nIMPORTANT: Manual review required for:")
    print("  - .put() conversions (need Companion objects)")
    print("  - Complex filters with .and() / .or()")
    print("  - .putAll() batch operations")
    print("  - Delete operations")
    print("\nRun: grep -r 'TODO: Convert' lib/")

if __name__ == '__main__':
    main()
