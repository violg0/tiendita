import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../models/Producto.dart';

class ProductoService {
  static final Uri _productosUri = Uri.https(
    'fakestoreapi.com',
    '/products',
  );

  final http.Client _cliente;

  ProductoService({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  Future<List<Producto>> listar() async {
    final response = await _cliente.get(_productosUri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductoApiException(
        'HTTP ${response.statusCode}: no se pudo cargar el catálogo',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const ProductoApiException(
        'La API devolvió una respuesta JSON inválida',
      );
    }

    if (decoded is! List) {
      throw const ProductoApiException(
        'La respuesta de la API no contiene una lista de productos',
      );
    }

    try {
      return decoded
          .map(
            (producto) => Producto.fromJson(
              Map<String, dynamic>.from(producto as Map),
            ),
          )
          .toList();
    } on FormatException {
      throw const ProductoApiException(
        'La API devolvió un producto con formato inválido',
      );
    } on TypeError {
      throw const ProductoApiException(
        'La API devolvió un producto con formato inválido',
      );
    }
  }
}

class ProductoApiException implements Exception {
  final String message;

  const ProductoApiException(this.message);

  @override
  String toString() => message;
}
