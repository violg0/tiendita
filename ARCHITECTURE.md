# Arquitectura de `lib/`

## Resumen

El código de `lib/` está organizado por responsabilidades: pantallas (`view`), componentes visuales reutilizables (`components`), modelos (`models`), acceso a servicios (`services`) y persistencia local (`repository`). El catálogo se carga mediante HTTP/JSON desde Fake Store API; las notas se guardan en Drift/SQLite y se sincronizan con Firestore.

**Importante:** algunas piezas todavía no están conectadas entre sí y hay referencias incompatibles entre pantallas, modelos y servicios. Por eso, la arquitectura que parece buscar el código no coincide por completo con lo que actualmente puede ejecutarse.

## Estructura de carpetas

- `lib/main.dart`: punto de entrada de Flutter.
- `lib/view/`: pantallas principales.
- `lib/components/`: widgets reutilizables.
- `lib/models/`: objetos de datos y conversión JSON.
- `lib/services/`: acceso a servicios remotos y persistencia de notas.
  - `lib/services/producto/`: consulta HTTP/JSON al catálogo.
  - `lib/services/nota/`: acceso remoto y local para notas.
- `lib/repository/`: definición de la base de datos local de Drift.
- `lib/assets/image/`: contiene imágenes de productos (`lenovo.jpg`, `mouse.jpg` y `teclado.jpg`).
- `lib/.gitignore`: reglas de exclusión de Git dentro de `lib`.
- `lib/Taller_Integrador_2_3_Persistencia_Sincronizacion (1) (2).pdf`: especificación del taller.

## Inicio y flujo de pantallas

### Entrada de la aplicación

En `lib/main.dart`:

- `main()` llama a `runApp(const MyApp())`.
- `MyApp.build()` devuelve un `MaterialApp` cuya pantalla actual es un `Scaffold` con el texto “TiendaTech”.

`main.dart` inicializa Firebase cuando está configurado y abre `ProductosPage`.

### Catálogo

`lib/view/ProductosPage.dart` contiene:

- `ProductosPage`: recibe un `ProductoService`, o crea uno si no se le inyecta.
- `_ProductosPageState.initState()`: inicia la carga de productos.
- `_cargarProductos()`: llama a `productoService.listar()`, limita la espera a 10 segundos, diferencia timeout de otros errores HTTP/JSON y actualiza el estado de la pantalla.
- `_cambiarEstado()`: cambia el estado de carga si el widget sigue montado.
- `_abrirDetalle()`: navega a `ProductoDetallePage` al seleccionar un producto.
- `build()`: construye la pantalla y su barra superior.
- `_construirCuerpo()`: selecciona qué mostrar según `EstadoCarga`: indicador, cuadrícula o mensaje.
- `_construirGrid()`: crea una tarjeta por producto mediante `ProductoCard`.
- `_construirMensaje()`: presenta el error o estado vacío y permite reintentar.

El enum `EstadoCarga` define `cargando`, `exito`, `vacio`, `timeout` y `error`.

### Tarjeta de producto

`lib/components/ProductoCard.dart` recibe un producto y una función `onTap`.

- `build()` crea la tarjeta y delega el contenido en los métodos privados.
- `_construirImagen()` carga la imagen desde la URL del producto y muestra un indicador o un placeholder durante la carga o ante un error.
- `_construirPlaceholder()` muestra un icono cuando no se puede usar la imagen.
- `_construirTextos()` presenta el nombre y el precio.

La tarjeta no decide la navegación: al tocarla ejecuta el callback que le entrega `ProductosPage`.

### Detalle de producto

`lib/view/ProductoDetallePage.dart` recibe un producto y un repositorio de notas.

- `initState()` carga el registro local de notas del producto.
- `dispose()` libera el controlador del campo de texto.
- `_cargarRegistro()` recupera desde el repositorio la nota, prioridad y estado de sincronización guardados.
- `_validar()` comprueba que la prioridad sea al menos 2 y que el texto no esté vacío.
- `_guardar()` guarda el producto, texto y prioridad mediante el repositorio; muestra si quedó sincronizado o pendiente.
- `_mostrarMensaje()` presenta validaciones y resultados mediante un `SnackBar`.
- `_formatearFecha()` muestra la fecha y hora de actualización del registro.
- `build()` construye la página desplazable con imagen, información del producto, estado del registro y formulario.
- `_construirImagen()` carga la imagen del producto o recurre al placeholder.
- `_construirPlaceholder()` muestra el icono de imagen no disponible.
- `_construirInformacion()` presenta nombre, precio, categoría y código.
- `_construirEstado()` muestra el cargador, que no hay registro, o el estado Sincronizado/Pendiente y su fecha.
- `_construirFormulario()` presenta el selector de prioridad, campo de texto y botón de guardado.
- `_construirSelectorPrioridad()` dibuja cinco estrellas interactivas.

## Modelos

- `lib/models/Producto.dart`: representa un producto con `id`, `nombre`, `categoria` (texto), `precio` e `imagen`. `Producto.fromJson()` convierte un mapa JSON en un producto y `toJson()` hace la conversión inversa.
- `lib/models/Nota.dart`: representa una nota con `id`, `idProducto`, `texto`, `priority`, `updatedAt` y `pendingSync`. `Nota.fromJson()` y `toJson()` convierten los datos remotos; `pendingSync` es estado local y no se envía a Firestore. Si no se proporciona `updatedAt`, el constructor usa la fecha actual.

## Servicios

### Productos

`lib/services/producto/producto_service.dart` consulta `https://fakestoreapi.com/products` por HTTP.

- `listar()`: realiza la petición, valida el código HTTP y la forma del JSON y convierte cada producto a `Producto`.
- `ProductoApiException`: informa errores HTTP y respuestas JSON o productos con formato inválido; los errores de red se propagan a la vista.

La pantalla de catálogo llama a `listar()` y gestiona el timeout, los estados y el reintento.

### Notas remotas y sincronización

`lib/services/nota/nota_service.dart` utiliza la colección `notas` de Firestore. La persistencia local y la coordinación entre almacenamiento local y remoto pertenecen al repositorio.

- `listar()`: obtiene todas las notas ordenadas por `id`.
- `listarPorProducto()`: filtra las notas por producto.
- `obtenerPorId()`: busca una nota por ID.
- `guardar()`: escribe una nota en Firestore con un límite de 10 segundos. Los errores remotos se propagan para que el repositorio mantenga el registro marcado como pendiente.
- `eliminar()`: elimina la nota de Firestore.

La interfaz utiliza `NotaRepository` en lugar de llamar directamente a `NotaService`.

### Notas locales

`lib/services/nota/NotaLocalService.dart` define la clase `NotasLocalService`, que utiliza la instancia global `db` de Drift.

- `_aNota()`: convierte una fila local `NotaOffline` en un modelo `Nota`.
- `obtenerPorProducto()`: devuelve el registro local más reciente de un producto, o `null`.
- `obtenerPorIdProducto()`: obtiene las notas locales de un producto, ordenadas por fecha descendente.
- `listarPendientes()`: devuelve las notas que aún esperan sincronizarse.
- `guardar()`: inserta o actualiza una nota local y permite indicar si queda pendiente de sincronización.
- `marcarSincronizada()`: cambia `pendingSync` a `false`.
- `eliminar()`: elimina una nota local.

### Repositorio de notas

`lib/repository/nota_repository.dart` es el punto de entrada de la interfaz para las notas.

- `obtenerPorProducto()`: lee la nota desde Drift, incluso sin conexión.
- `guardar()`: escribe primero en Drift y después intenta sincronizar con Firestore; si el envío falla, conserva la nota local como pendiente.
- `sincronizarPendientes()`: procesa las notas pendientes y devuelve cuántas se enviaron y cuántas siguen pendientes.
- `_enviar()`: coordina el envío remoto y el cambio del indicador local a sincronizado.

El repositorio depende de `NotasLocalService` para Drift y de `NotaService` para Firestore.

## Persistencia local

`lib/repository/database.dart` define la tabla `NotasOffline` y la base de datos `AppDatabase`.

La tabla guarda:

- `id`: entero autoincremental.
- `idProducto`: identificador del producto asociado.
- `priority`: prioridad con valor predeterminado `1`.
- `texto`: contenido de la nota.
- `pendingSync`: indicador de sincronización pendiente, predeterminado a `true`.
- `updatedAt`: fecha de actualización, predeterminada a la fecha actual.

`AppDatabase` abre una base Drift llamada `tienda`, declara la versión de esquema `1` y activa `PRAGMA foreign_keys = ON` antes de abrirla.

`lib/repository/database.g.dart` es el archivo generado por Drift. Contiene las clases de soporte para consultas, filas, companions y administración de tablas; normalmente se regenera con las herramientas de Drift en lugar de editarse manualmente.

## Relaciones: quién llama a quién

```text
main()
└── MyApp
    └── MaterialApp → Scaffold de bienvenida actual

ProductosPage
├── ProductoService.listar()
│   └── HTTP/JSON: Fake Store API
└── ProductoCard
    └── onTap → ProductosPage._abrirDetalle()
        └── ProductoDetallePage
            ├── producto.categoria → muestra el texto de la categoría
            ├── NotaRepository.obtenerPorProducto()
            └── NotaRepository.guardar()

ProductosPage / ProductoDetallePage
└── NotaRepository
    ├── NotasLocalService
    │   └── db → AppDatabase/Drift → tabla NotasOffline
    └── NotaService
        └── Firestore: colección "notas"
```

El catálogo requiere internet y usa Fake Store API. Firestore requiere configuración Firebase para sincronizar; cuando no está disponible, las notas siguen guardándose localmente como pendientes.
