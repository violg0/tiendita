class Nota {
  final int id;
  final int idProducto;
  final String texto;
  final int priority;
  final DateTime updatedAt;

  Nota({
    required this.id,
    required this.idProducto,
    required this.texto,
    required this.priority,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      id: json["id"],
      idProducto: json["id_producto"],
      texto: json["texto"],
      priority: json["priority"] ?? 1,
      updatedAt: json["fecha"] != null ? DateTime.parse(json["fecha"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_producto": idProducto,
    "texto": texto,
    "priority": priority,
    "fecha": updatedAt.toIso8601String(),
  };
}
