import 'package:flutter_test/flutter_test.dart';
import 'package:tiendatech/main.dart';

void main() {
  testWidgets('muestra el titulo de la tienda', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('TiendaTech'), findsOneWidget);
  });
}