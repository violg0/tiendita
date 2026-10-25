class Nota {
  final String id;
  final String idProducto;
  final String texto;
  final DateTime fecha;

  Nota({
    required this.id,
    required this.idProducto,
    required this.texto,
    required this.fecha,
  });

  /// [id] es el id del documento en Firestore (no va dentro de los campos).
  factory Nota.fromJson(Map<String, dynamic> json, String id) {
    return Nota(
      id: id,
      idProducto: json["id_producto"],
      texto: json["texto"],
      fecha: DateTime.parse(json["fecha"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id_producto": idProducto,
    "texto": texto,
    "fecha": fecha.toIso8601String(),
  };
}