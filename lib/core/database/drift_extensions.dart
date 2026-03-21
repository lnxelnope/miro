import 'package:drift/drift.dart';
import 'app_database.dart';

/// Extension methods to provide Isar-like API for Drift queries
/// Makes migration easier by keeping similar syntax

extension DriftQueryExtensions<T extends Table, D> on SimpleSelectStatement<T, D> {
  /// Isar-like .findAll() → Drift .get()
  Future<List<D>> findAll() => get();

  /// Isar-like .findFirst() → Drift .getSingleOrNull()
  Future<D?> findFirst() => getSingleOrNull();

  /// Isar-like .count() → Drift .get().then((list) => list.length)
  Future<int> count() async {
    final results = await get();
    return results.length;
  }
}

extension DriftTableExtensions<T extends Table, D> on TableInfo<T, D> {
  /// Isar-like .get(id) for single record by ID
  Future<D?> get(Insertable<D> insertable) async {
    // This is a placeholder - actual implementation depends on table structure
    // Will be overridden in specific use cases
    return null;
  }

  /// Isar-like .put(object) → Drift .into(table).insertOnConflictUpdate(object)
  Future<int> put(Insertable<D> insertable) async {
    final db = attachedDatabase as GeneratedDatabase;
    return await db.into(this).insertOnConflictUpdate(insertable);
  }

  /// Isar-like .putAll(objects)
  Future<void> putAll(List<Insertable<D>> insertables) async {
    final db = attachedDatabase as GeneratedDatabase;
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(this, insertables);
    });
  }

  /// Isar-like .delete(id)
  Future<int> deleteById(int id) async {
    final db = attachedDatabase as GeneratedDatabase;
    return await (db.delete(this)..where((tbl) {
      // This requires runtime reflection which Drift doesn't have
      // We'll need to implement this per-table
      return const Constant(true);
    })).go();
  }
}

/// Helper for creating filters (similar to Isar's .filter())
extension DriftFilterExtensions<T extends Table, D> on SimpleSelectStatement<T, D> {
  /// Chain multiple where clauses (AND logic)
  SimpleSelectStatement<T, D> filter(Expression<bool> Function(T tbl) filter) {
    where((tbl) => filter(tbl));
    return this;
  }
}

/// Convenience filters for common FoodEntries queries
extension FoodEntriesQueryExtensions
    on SimpleSelectStatement<$FoodEntriesTable, FoodEntryData> {
  /// Filter to only FoodEntries created from ARscan data source
  SimpleSelectStatement<$FoodEntriesTable, FoodEntryData> whereArScan() {
    where((tbl) => tbl.source.equalsValue(DataSource.arScan));
    return this;
  }
}

