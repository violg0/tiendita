import 'dart:async' show TimeoutException;
import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http show get;
import 'package:tiendatech/models/producto.dart' show Producto;

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ProductService{
  final String baseUrl;
  ProductService(this.baseUrl);

  Future <List<Producto>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    try{
      final response = await http
      .get(Uri.parse(this.baseUrl))
      .timeout(const Duration(seconds: 10));

      if(response.statusCode == 404){
        throw Exception('Api does not exist');
      }

      if(response.statusCode == 500){
        throw Exception('this problem is in the API');
      }

      if(response.statusCode != 200){
        throw Exception('could not load movies');
      }

      if(response.statusCode >= 500){
        throw const ApiException('there is an error with ther server');
      }

      if(response.statusCode == 200){
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Producto.fromJson(item))
          .toList();
      }

      throw ApiException('error http ${response.statusCode}');
      }on TimeoutException {
        throw const ApiException('the server request took too long to answer');
      }
  }
}