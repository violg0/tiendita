/// Error del catálogo con un mensaje que el usuario puede leer.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      statusCode == null ? message : 'Error $statusCode: $message';
}
