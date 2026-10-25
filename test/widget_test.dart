import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tiendatech/models/Nota.dart';
import 'package:tiendatech/models/Producto.dart';
import 'package:tiendatech/repository/nota_repository.dart';
import 'package:tiendatech/services/producto/producto_service.dart';
import 'package:tiendatech/view/ProductoDetallePage.dart';
import 'package:tiendatech/view/ProductosPage.dart';

void main() {
  testWidgets('catalog displays products returned by the API', (tester) async {
    final repository = _FakeNotaRepository();
    final service = ProductoService(
      cliente: MockClient((_) async => http.Response(_productsJson, 200)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductosPage(productoService: service, repositorio: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test phone'), findsOneWidget);
    expect(find.text('\$123.45'), findsOneWidget);
  });

  testWidgets('catalog displays API errors and supports retry', (tester) async {
    var requests = 0;
    final repository = _FakeNotaRepository();
    final service = ProductoService(
      cliente: MockClient((_) async {
        requests++;
        if (requests == 1) return http.Response('unavailable', 503);
        return http.Response(_productsJson, 200);
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductosPage(productoService: service, repositorio: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('HTTP 503'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Test phone'), findsOneWidget);
  });

  testWidgets('catalog displays an empty state for an empty API list', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductosPage(
          productoService: ProductoService(
            cliente: MockClient((_) async => http.Response('[]', 200)),
          ),
          repositorio: _FakeNotaRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay productos'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('catalog sync button delegates to the repository', (
    tester,
  ) async {
    final repository = _FakeNotaRepository(
      syncResult: (enviados: 2, fallidos: 1),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ProductosPage(
          productoService: ProductoService(
            cliente: MockClient((_) async => http.Response('[]', 200)),
          ),
          repositorio: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sincronizar pendientes'));
    await tester.pumpAndSettle();

    expect(repository.syncCalls, 1);
    expect(
      find.text('Se sincronizaron 2; 1 siguen pendientes'),
      findsOneWidget,
    );
  });

  testWidgets('detail blocks saving a priority below two', (tester) async {
    final repository = _FakeNotaRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ProductoDetallePage(producto: _product, repositorio: repository),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('No hay información guardada'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'A personal note');
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(
      find.text('La prioridad debe ser 2 o más para guardar'),
      findsOneWidget,
    );
    expect(repository.saveCalls, 0);
  });

  testWidgets('detail saves and displays the pending local status', (
    tester,
  ) async {
    final repository = _FakeNotaRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ProductoDetallePage(producto: _product, repositorio: repository),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.star_border).at(1));
    await tester.enterText(find.byType(TextField), 'A personal note');
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(repository.saveCalls, 1);
    expect(find.text('Pendiente'), findsOneWidget);
  });
}

const _productsJson = '''
[
  {
    "id": 1,
    "title": "Test phone",
    "category": "electronics",
    "price": 123.45,
    "image": "https://example.com/phone.jpg"
  }
]
''';

final _product = Producto(
  id: 1,
  nombre: 'Test phone',
  categoria: 'electronics',
  precio: 123.45,
  imagen: 'https://example.com/phone.jpg',
);

class _FakeNotaRepository implements NotaRepository {
  _FakeNotaRepository({this.syncResult = (enviados: 0, fallidos: 0)});

  final ({int enviados, int fallidos}) syncResult;
  Nota? _nota;
  int saveCalls = 0;
  int syncCalls = 0;

  @override
  Future<Nota?> obtenerPorProducto(int idProducto) async => _nota;

  @override
  Future<Nota> guardar({
    required int idProducto,
    required String texto,
    required int priority,
  }) async {
    saveCalls++;
    return _nota = Nota(
      id: idProducto,
      idProducto: idProducto,
      texto: texto,
      priority: priority,
      pendingSync: true,
    );
  }

  @override
  Future<({int enviados, int fallidos})> sincronizarPendientes() async {
    syncCalls++;
    return syncResult;
  }
}
