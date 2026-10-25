import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tiendatech/components/ProductoCard.dart' show ProductoCard;
import 'package:tiendatech/repository/database.dart' show Producto;
import 'package:tiendatech/services/producto/producto_service.dart'
    show ProductoService;
import 'package:tiendatech/view/ProductoDetallePage.dart'
    show ProductoDetallePage;

/// Los estados posibles de la pantalla (los que dibujaste en el boceto).
enum EstadoCarga { cargando, exito, vacio, timeout, error }

/// Pantalla que muestra los productos en una cuadrícula (matriz) de tarjetas.
///
/// Responsabilidades:
/// - Pedir los productos al servicio.
/// - Elegir qué dibujar según el estado.
/// - Navegar al detalle cuando se toca una tarjeta.
///
/// El servicio llega por el constructor (inyección de dependencias),
/// así esta pantalla no depende de cómo está construido por dentro.
class ProductosPage extends StatefulWidget {
  final ProductoService productoService;

  ProductosPage({super.key, ProductoService? productoService})
    : productoService = productoService ?? ProductoService();

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  static const Duration _tiempoMaximo = Duration(seconds: 10);

  EstadoCarga _estado = EstadoCarga.cargando;
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  // ---------- LÓGICA ----------

  Future<void> _cargarProductos() async {
    setState(() => _estado = EstadoCarga.cargando);

    try {
      final productos = await widget.productoService.listar().timeout(
        _tiempoMaximo,
      );

      if (!mounted) return;
      setState(() {
        _productos = productos;
        _estado = productos.isEmpty ? EstadoCarga.vacio : EstadoCarga.exito;
      });
    } on TimeoutException {
      _cambiarEstado(EstadoCarga.timeout);
    } catch (_) {
      _cambiarEstado(EstadoCarga.error);
    }
  }

  void _cambiarEstado(EstadoCarga nuevoEstado) {
    if (!mounted) return;
    setState(() => _estado = nuevoEstado);
  }

  void _abrirDetalle(Producto producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoDetallePage(producto: producto),
      ),
    );
  }

  // ---------- INTERFAZ ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    switch (_estado) {
      case EstadoCarga.cargando:
        return const Center(child: CircularProgressIndicator());
      case EstadoCarga.exito:
        return _construirGrid();
      case EstadoCarga.vacio:
        return _construirMensaje('No hay productos');
      case EstadoCarga.timeout:
        return _construirMensaje('Timeout');
      case EstadoCarga.error:
        return _construirMensaje('Error de petición');
    }
  }

  Widget _construirGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _productos.length,
      itemBuilder: (context, index) {
        final producto = _productos[index];
        return ProductoCard(
          producto: producto,
          onTap: () => _abrirDetalle(producto),
        );
      },
    );
  }

  Widget _construirMensaje(String texto) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(texto, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _cargarProductos,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
