import 'package:drift/drift.dart';
import 'package:drift/drift.dart' show Value;
import 'package:tiendatech/models/Nota.dart' show Nota;
import 'package:tiendatech/repository/database.dart';

class NotasLocalService {
  Nota _aNota(NotaOffline fila) => Nota(
    id: fila.id,
    idProducto: fila.idProducto,
    texto: fila.texto,
    priority: fila.priority,
    updatedAt: fila.updatedAt,
  );
  /*

  // READ: una por id (null si no existe)
  Future<NotaOffline?> obtenerPorId(int id) {
    return (db.select(
      db.notasOffline,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }
*/

  // READ: notas de un producto, como Nota (las más recientes primero)
  Future<List<Nota>> obtenerPorIdProducto(int idProducto) async {
    final filas =
        await (db.select(db.notasOffline)
              ..where((n) => n.idProducto.equals(idProducto))
              ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
            .get();

    return filas.map(_aNota).toList();
  }

  // CREATE y UPDATE: inserta si el id no existe, actualiza si existe
  Future<void> guardar(Nota nota) {
    return db
        .into(db.notasOffline)
        .insertOnConflictUpdate(
          NotasOfflineCompanion(
            id: Value(nota.id),
            idProducto: Value(nota.idProducto),
            priority: Value(nota.priority),
            texto: Value(nota.texto),
          ),
        );
  }

  // DELETE
  Future<void> eliminar(int id) {
    return (db.delete(db.notasOffline)..where((c) => c.id.equals(id))).go();
  }
}
