import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
}

class Productos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  IntColumn get idCategoria => integer().references(Categorias, #id)();
  IntColumn get precio => integer()();
  TextColumn get imagen => text().nullable()();
}

class Notas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get idProducto => integer().references(Productos, #id)();
  TextColumn get texto => text()();
  DateTimeColumn get fecha => dateTime()();
}

@DriftDatabase(tables: [Categorias, Productos, Notas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'tienda'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}