
class Producto {
  final int id;
  String nombre;
  String categoria;
  double precio;
  int disponibilidad;
  final String descripcion;
  final String imagePath;


  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.disponibilidad,
    required this.descripcion,
    required this.imagePath
  });

  factory Producto.fromJson(Map<String, dynamic> json){
      return Producto(
      id: json["id"],
      nombre: json['nombre'],
      categoria: json['categoria'],
      precio: (json['precio'] as num).toDouble(),
      disponibilidad: json['disponibilidad'],
      descripcion: json['descripcion'],
      imagePath: json['imagePath']
      );
    }


}
