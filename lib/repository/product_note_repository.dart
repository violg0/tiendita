import 'package:drift/drift.dart';

import '../repository/database.dart';

class ProductNoteRepository {
  final AppDatabase _db;

  ProductNoteRepository([AppDatabase? database]) : _db = database ?? db;

  /// Devuelve la nota guardada de un producto, o null si no hay ninguna.
  Future<ProductNote?> getNote(int productId) {
    return (_db.select(_db.productNotes)
          ..where((n) => n.productId.equals(productId.toString())))
        .getSingleOrNull();
  }

  /// Guarda en Drift. Si ya existe una nota de ese producto, la actualiza.
  Future<void> saveNote({
    required int productId,
    required String note,
    required int priority,
  }) {
    return _db.into(_db.productNotes).insertOnConflictUpdate(
          ProductNotesCompanion(
            productId: Value(productId.toString()),
            note: Value(note),
            priority: Value(priority),
            updatedAt: Value(DateTime.now()),
            pendingSync: const Value(true),
          ),
        );
  }
}