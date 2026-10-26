import 'package:drift/drift.dart';
import 'package:tiendatech/models/Nota.dart' show Nota;
import 'package:tiendatech/repository/database.dart';

class NotasLocalService {
  Nota _aNota(NotaOffline fila) => Nota(
    id: fila.id,
    idProducto: fila.idProducto,
    texto: fila.texto,
    priority: fila.priority,
    updatedAt: fila.updatedAt,
    pendingSync: fila.pendingSync,
  );

  Future<Nota?> obtenerPorProducto(int idProducto) async {
    final fila =
        await (db.select(db.notasOffline)
              ..where((n) => n.idProducto.equals(idProducto))
              ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])
              ..limit(1))
            .getSingleOrNull();

    return fila == null ? null : _aNota(fila);
  }

  Future<List<Nota>> obtenerPorIdProducto(int idProducto) async {
    final filas =
        await (db.select(db.notasOffline)
              ..where((n) => n.idProducto.equals(idProducto))
              ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
            .get();

    return filas.map(_aNota).toList();
  }

  Future<List<Nota>> listarPendientes() async {
    final filas = await (db.select(db.notasOffline)
          ..where((n) => n.pendingSync.equals(true))
          ..orderBy([(n) => OrderingTerm.asc(n.updatedAt)]))
        .get();

    return filas.map(_aNota).toList();
  }

  Future<void> guardar(Nota nota, {bool pendingSync = true}) {
    return db
        .into(db.notasOffline)
        .insertOnConflictUpdate(
          NotasOfflineCompanion(
            id: Value(nota.id),
            idProducto: Value(nota.idProducto),
            priority: Value(nota.priority),
            texto: Value(nota.texto),
            pendingSync: Value(pendingSync),
            updatedAt: Value(nota.updatedAt),
          ),
        );
  }

  Future<void> marcarSincronizada(int id) {
    return (db.update(db.notasOffline)..where((n) => n.id.equals(id))).write(
      const NotasOfflineCompanion(pendingSync: Value(false)),
    );
  }

  Future<void> eliminar(int id) {
    return (db.delete(db.notasOffline)..where((c) => c.id.equals(id))).go();
  }
}
