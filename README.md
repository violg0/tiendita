# TiendaTech

Tienda de hobbies hecha en Flutter para el taller Integrador 2 + 3 de Desarrollo Móvil (Persistencia y sincronización). Muestra un catálogo de productos y permite guardar una prioridad y una nota por producto, primero en el dispositivo y después en la nube.

## Integrantes

- Violeta Agudelo
- Lenin Ospina

## Requisitos

- Flutter con Dart SDK `^3.11.5` (el que figura en `pubspec.yaml`).
- Un emulador de Android o un dispositivo.
- Conexión a internet: el catálogo viene de Fake Store API (`https://fakestoreapi.com/products`).

## Cómo ejecutar

```bash
flutter pub get
flutter run -d <id del emulador>
```

Para ver los ids disponibles: `flutter devices`.

## Qué hace la app

- Catálogo de productos en una cuadrícula, con los estados de carga, error, vacío y datos. Si la petición tarda más de 10 segundos muestra "Timeout", y en los casos de error, vacío o timeout hay un botón **Reintentar**.
- Detalle de cada producto con una prioridad de 1 a 5 y una nota personal.
- Solo guarda si la prioridad es 2 o mayor (y la nota no está vacía); si no, muestra un mensaje y no guarda nada.
- Guarda la nota en el dispositivo con Drift y muestra si está "Pendiente" o "Sincronizado".
- Sincroniza la nota con Firestore después de guardarla en local.
- El botón **Sincronizar pendientes** está en la pantalla del catálogo (arriba de la cuadrícula) y envía solo los registros con `pendingSync` en true.

## Arquitectura

| Capa | Qué es | Archivo |
|---|---|---|
| Modelo | `Producto` y `Nota` | `lib/models/Producto.dart`, `lib/models/Nota.dart` |
| Servicio de productos | `ProductoService` (pide `/products` a Fake Store API) | `lib/services/producto/producto_service.dart` |
| Pantallas | `ProductosPage` (catálogo) y `ProductoDetallePage` (detalle) | `lib/view/ProductosPage.dart`, `lib/view/ProductoDetallePage.dart` |
| Repository | `NotaRepository` (la UI solo habla con él) | `lib/repository/nota_repository.dart` |
| Base local | Drift, tabla `NotasOffline` con los campos `id`, `idProducto`, `priority`, `texto`, `pendingSync` y `updatedAt` | `lib/repository/database.dart`, `lib/services/nota/NotaLocalService.dart` |
| Nube | `NotaService`: colección `notas` de Firestore, con el id de la nota (igual al `idProducto`) como id del documento | `lib/services/nota/nota_service.dart` |

## Firebase

La configuración está en `lib/firebase_options.dart` y `android/app/google-services.json`, y `lib/main.dart` la usa al iniciar la app. Las notas se escriben en la colección `notas`, y como el id del documento es el id del producto, reenviar una nota no crea duplicados. Sin internet (o si Firebase falla), la nota queda guardada en Drift como pendiente y la app sigue funcionando; se envía después con "Sincronizar pendientes".

## Plataforma recomendada

El proyecto se probó en el emulador de Android. En Chrome/Edge Drift no guarda sin configuración adicional.

## Pruebas

```bash
flutter test
```

## Preguntas

### 1. ¿Para qué sirve pendingSync?

pendingSync es una marca que se guarda con cada nota en Drift para saber si ya se envió a Firestore. Si vale true, la nota solo está en el celular y queda pendiente; cuando Firestore confirma el envío pasa a false. Con eso la app muestra Pendiente o Sincronizado y sabe cuáles notas enviar al pulsar "Sincronizar pendientes".

### 2. ¿Por qué se guarda primero en Drift?

Porque Drift funciona en el celular sin necesidad de internet. Si se guardara primero en Firestore y la red fallara, la nota se perdería. Guardando antes en Drift la nota siempre queda a salvo y después se intenta enviar a la nube.

### 3. ¿Qué función cumple el Repository?

El Repository es la capa que usa la pantalla para leer, guardar y sincronizar las notas. La pantalla no sabe nada de Drift ni de Firestore: el Repository guarda en local, intenta enviar y marca el resultado. Así el código queda ordenado y cada parte hace una sola cosa.

### 4. ¿Qué ocurre si Firebase falla?

La nota no se pierde, porque ya quedó guardada en Drift. Se queda con pendingSync en true, es decir, como Pendiente, y la app sigue funcionando sin mostrar un error grave. Cuando haya conexión se puede enviar con el botón "Sincronizar pendientes".
