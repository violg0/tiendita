import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tiendatech/components/ProductoCard.dart' show ProductoCard;
import 'package:tiendatech/models/Producto.dart' show Producto;
import 'package:tiendatech/repository/nota_repository.dart' show NotaRepository;
import 'package:tiendatech/services/producto/producto_service.dart'
    show ProductoService;
import 'package:tiendatech/view/ProductoDetallePage.dart'
    show ProductoDetallePage;

enum EstadoCarga { cargando, exito, vacio, timeout, error }

class ProductosPage extends StatefulWidget {
  final ProductoService productoService;
  final NotaRepository repositorio;

  ProductosPage({
    super.key,
    ProductoService? productoService,
    NotaRepository? repositorio,
  }) : productoService = productoService ?? ProductoService(),
       repositorio = repositorio ?? NotaRepository();

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  static const Duration _tiempoMaximo = Duration(seconds: 10);

  EstadoCarga _estado = EstadoCarga.cargando;
  List<Producto> _productos = [];
  String? _detalleError;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }


  Future<void> _cargarProductos() async {
    setState(() {
      _estado = EstadoCarga.cargando;
      _detalleError = null;
    });

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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detalleError = e.toString().replaceFirst('Exception: ', '');
        _estado = EstadoCarga.error;
      });
    }
  }

  void _cambiarEstado(EstadoCarga nuevoEstado) {
    if (!mounted) return;
    setState(() => _estado = nuevoEstado);
  }

  Future<void> _sincronizarPendientes() async {
    setState(() => _sincronizando = true);

    String mensaje;
    try {
      final resultado = await widget.repositorio.sincronizarPendientes();
      mensaje = _mensajeSincronizacion(resultado.enviados, resultado.fallidos);
    } catch (_) {
      mensaje = 'No se pudo sincronizar. Inténtalo de nuevo';
    }

    if (!mounted) return;
    setState(() => _sincronizando = false);
    _mostrarMensaje(mensaje);
  }

  String _mensajeSincronizacion(int enviados, int fallidos) {
    if (enviados == 0 && fallidos == 0) return 'No hay registros pendientes';
    if (fallidos == 0) return 'Se sincronizaron $enviados registro(s)';
    return 'Se sincronizaron $enviados; $fallidos siguen pendientes';
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  void _abrirDetalle(Producto producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoDetallePage(
          producto: producto,
          repositorio: widget.repositorio,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: Column(
        children: [
          _construirBotonSincronizar(),
          Expanded(child: _construirCuerpo()),
        ],
      ),
    );
  }

  Widget _construirBotonSincronizar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _sincronizando ? null : _sincronizarPendientes,
          icon: _sincronizando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          label: Text(
            _sincronizando ? 'Sincronizando...' : 'Sincronizar pendientes',
          ),
        ),
      ),
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
        return _construirMensaje('Error de petición', detalle: _detalleError);
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

  Widget _construirMensaje(String texto, {String? detalle}) {
    final textos = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texto, style: textos.titleMedium),
            if (detalle != null && detalle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                detalle,
                textAlign: TextAlign.center,
                style: textos.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cargarProductos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
