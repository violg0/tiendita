class ProductoLocalService {
  final AppDatabase _db;
  ProductoLocalService([AppDatabase? database]) : _db = database ?? db;

  Future<List<Producto>> listar() {
    return (_db.select(
      _db.productos,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
  }

  Stream<List<Producto>> observar({int? idCategoria}) {
    final consulta = _db.select(_db.productos)
      ..orderBy([(p) => OrderingTerm.asc(p.id)]);
    if (idCategoria != null) {
      consulta.where((p) => p.idCategoria.equals(idCategoria));
    }
    return consulta.watch();
  }

  Future<Producto?> obtenerPorId(int id) {
    return (_db.select(
      _db.productos,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<List<Producto>> listarPorCategoria(int idCategoria) {
    return (_db.select(
      _db.productos,
    )..where((p) => p.idCategoria.equals(idCategoria))).get();
  }

  Future<void> guardar(Producto p) {
    return _db
        .into(_db.productos)
        .insertOnConflictUpdate(
          ProductosCompanion(
            id: Value(p.id),
            nombre: Value(p.nombre),
            idCategoria: Value(p.idCategoria),
            precio: Value(p.precio),
            imagen: Value(p.imagen),
          ),
        );
  }

  Future<void> eliminar(int id) {
    return (_db.delete(_db.productos)..where((p) => p.id.equals(id))).go();
  }

  Future<int> siguienteId() async {
    final maxId = _db.productos.id.max();
    final fila = await (_db.selectOnly(
      _db.productos,
    )..addColumns([maxId])).getSingle();
    return (fila.read(maxId) ?? 0) + 1;
  }
}

class NotaLocalService {
  final AppDatabase _db;
  NotaLocalService([AppDatabase? database]) : _db = database ?? db;

  Future<List<Nota>> listar() {
    return (_db.select(
      _db.notas,
    )..orderBy([(n) => OrderingTerm.asc(n.id)])).get();
  }

  Future<Nota?> obtenerPorId(int id) {
    return (_db.select(
      _db.notas,
    )..where((n) => n.id.equals(id))).getSingleOrNull();
  }

  Future<List<Nota>> listarPorProducto(int idProducto) {
    return (_db.select(_db.notas)
          ..where((n) => n.idProducto.equals(idProducto))
          ..orderBy([(n) => OrderingTerm.desc(n.fecha)]))
        .get();
  }

  Stream<List<Nota>> observarPorProducto(int idProducto) {
    return (_db.select(_db.notas)
          ..where((n) => n.idProducto.equals(idProducto))
          ..orderBy([(n) => OrderingTerm.desc(n.fecha)]))
        .watch();
  }

  Future<void> guardar(Nota n) {
    return _db
        .into(_db.notas)
        .insertOnConflictUpdate(
          NotasCompanion(
            id: Value(n.id),
            idProducto: Value(n.idProducto),
            texto: Value(n.texto),
            fecha: Value(n.fecha),
          ),
        );
  }

  Future<void> eliminar(int id) {
    return (_db.delete(_db.notas)..where((n) => n.id.equals(id))).go();
  }

  Future<int> siguienteId() async {
    final maxId = _db.notas.id.max();
    final fila = await (_db.selectOnly(
      _db.notas,
    )..addColumns([maxId])).getSingle();
    return (fila.read(maxId) ?? 0) + 1;
  }
}
