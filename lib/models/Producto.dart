class Producto {
  final int id;
  final String nombre;
  final String categoria;
  final double precio;
  final String imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nombre = json['title'] ?? json['nombre'];
    final categoria = json['category'] ?? json['categoria'];
    final precio = json['price'] ?? json['precio'];
    final imagen = json['image'] ?? json['imagen'];

    if (id is! int ||
        nombre is! String ||
        categoria is! String ||
        precio is! num ||
        imagen is! String) {
      throw const FormatException('Formato de producto inválido');
    }

    return Producto(
      id: id,
      nombre: nombre,
      categoria: categoria,
      precio: precio.toDouble(),
      imagen: imagen,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": nombre,
    "category": categoria,
    "price": precio,
    "image": imagen,
  };
}
