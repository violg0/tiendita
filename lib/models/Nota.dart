class Nota {
  final int id;
  final int idProducto;
  final String texto;
  final DateTime fecha;

  Nota({
    required this.id,
    required this.idProducto,
    required this.texto,
    required this.fecha,
  });

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      id: json["id"],
      idProducto: json["id_producto"],
      texto: json["texto"],
      fecha: DateTime.parse(json["fecha"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_producto": idProducto,
    "texto": texto,
    "fecha": fecha.toIso8601String(),
  };
}
