import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'api_exception.dart';

/// Pide el catálogo al servidor, valida la respuesta y la convierte en
/// objetos [Product]. No dibuja nada ni guarda nada.
class ProductService {
  final String baseUrl;
  final Duration timeout;

  const ProductService(
    this.baseUrl, {
    this.timeout = const Duration(seconds: 8),
  });

  Future<List<Product>> getProducts() async {
    final http.Response response;
    try {
      response = await http.get(Uri.parse('$baseUrl/products')).timeout(timeout);
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder');
    } on http.ClientException {
      throw const ApiException('No hay conexión con el servidor');
    }

    if (response.statusCode == 404) {
      throw const ApiException('Catálogo no encontrado', statusCode: 404);
    }
    if (response.statusCode >= 500) {
      throw ApiException(
        'Problema del servidor',
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode != 200) {
      throw ApiException(
        'No se pudo cargar el catálogo',
        statusCode: response.statusCode,
      );
    }

    try {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => Product.fromJson(item)).toList();
    } catch (_) {
      throw const ApiException('La respuesta del servidor no es válida');
    }
  }
}
