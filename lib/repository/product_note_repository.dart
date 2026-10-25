import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../repository/database.dart';

class ProductNoteRepository {
  final AppDatabase _db;

  ProductNoteRepository([AppDatabase? database]) : _db = database ?? db;

  /// Nota guardada de un producto, o null si no hay ninguna.
  Future<ProductNote?> getNote(int productId) {
    return (_db.select(_db.productNotes)
          ..where((n) => n.productId.equals(productId.toString())))
        .getSingleOrNull();
  }

  /// Offline-first: guarda en Drift (pendiente) y después intenta Firestore.
  /// Devuelve true si además quedó sincronizada.
  Future<bool> saveNote({
    required int productId,
    required String note,
    required int priority,
  }) async {
    await _db.into(_db.productNotes).insertOnConflictUpdate(
          ProductNotesCompanion(
            productId: Value(productId.toString()),
            note: Value(note),
            priority: Value(priority),
            updatedAt: Value(DateTime.now()),
            pendingSync: const Value(true),
          ),
        );

    final saved = await getNote(productId);
    if (saved == null) return false;
    return _sync(saved);
  }

  /// Envía solo los registros con pendingSync == true.
  Future<({int sent, int total})> syncPending() async {
    final pending = await (_db.select(_db.productNotes)
          ..where((n) => n.pendingSync.equals(true)))
        .get();

    var sent = 0;
    for (final n in pending) {
      if (await _sync(n)) sent++;
    }
    return (sent: sent, total: pending.length);
  }

  /// Envía una nota y, si llegó, la marca como sincronizada.
  Future<bool> _sync(ProductNote n) async {
    try {
      await FirebaseFirestore.instance
          .collection('product_notes')
          .doc(n.productId) // el id del documento es el productId
          .set({
        'productId': n.productId,
        'note': n.note,
        'priority': n.priority,
        'updatedAt': Timestamp.fromDate(n.updatedAt),
      }).timeout(const Duration(seconds: 8));
    } catch (_) {
      return false; // Firebase falló: lo local queda intacto y pendiente
    }

    await (_db.update(_db.productNotes)
          ..where((t) => t.productId.equals(n.productId)))
        .write(const ProductNotesCompanion(pendingSync: Value(false)));
    return true;
  }
}