// =====================================================
 
class CategoriaLocalService {
  final AppDatabase _db;
  CategoriaLocalService([AppDatabase? database]) : _db = database ?? db;
 
  Future<List<Categoria>> listar() {
    return (_db.select(_db.categorias)
          ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .get();
  }
 
  Stream<List<Categoria>> observar() {
    return (_db.select(_db.categorias)
          ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .watch();
  }
 
  Future<Categoria?> obtenerPorId(int id) {
    return (_db.select(_db.categorias)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }
 
  // Inserta o actualiza (equivale al .set() de Firestore)
  Future<void> guardar(Categoria c) {
    return _db.into(_db.categorias).insertOnConflictUpdate(
          CategoriasCompanion(id: Value(c.id), nombre: Value(c.nombre)),
        );
  }
 
  Future<void> eliminar(int id) {
    return (_db.delete(_db.categorias)..where((c) => c.id.equals(id))).go();
  }
 
  Future<int> siguienteId() async {
    final maxId = _db.categorias.id.max();
    final fila =
        await (_db.selectOnly(_db.categorias)..addColumns([maxId])).getSingle();
    return (fila.read(maxId) ?? 0) + 1;
  }
}