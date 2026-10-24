class Producto {
  final int id;
  final String nombre;
  final int idCategoria;
  final int precio;
  final String imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.idCategoria,
    required this.precio,
    required this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json["id"],
      nombre: json["nombre"],
      idCategoria: json["id_categoria"],
      precio: json["precio"],
      imagen: json["imagen"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "id_categoria": idCategoria,
    "precio": precio,
    "imagen": imagen,
  };
}
