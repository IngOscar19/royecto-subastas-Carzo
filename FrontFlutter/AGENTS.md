# Estado actual

El proyecto Flutter vive en `subastas_app/` (Flutter 3.44.4, Dart 3.12.2). 
Implementado y verificado: auth funcional (login + registro con selector de 
rol), persistencia de sesión (JWT + user en flutter_secure_storage), 
redirect por rol con go_router (Riverpod) y homes de rol placeholder. 
Pendiente: features de auctions (catálogo/publicación), bids (pujas) y 
WebSocket.

Implementado: catálogo de subastas activas en la home del comprador
(`GET /auctions?status=active`) con imagen, título, precio, countdown y
navegación al detalle en tiempo real. La pantalla de detalle muestra
título/imagen/descripción vía `GET /auctions/:id` (REST) y precio/tiempo/
pujas en vivo vía WebSocket. Las imágenes son rutas relativas
(`/images/...`) servidas por el backend desde `ProyectoBack/public/`; el
modelo `Auction.coverUrl` (primera imagen) y `Auction.imageUrls` (todas,
hasta 3) las resuelven contra `Env.apiBaseUrl`. La UI muestra la galería
con `ImageGallery` (carrusel deslizable con puntos y contador) en la tarjeta
del catálogo y en el detalle.
Scripts de datos: `ProyectoBack/scripts/fetch-auction-images.mjs`
(descarga hasta 3 imágenes por vehículo desde Wikipedia/Commons, con
overrides curados para vehículos concretos; soporta `--offline` para usar
los archivos ya descargados sin API/BD) y `attach-images.mjs` (asigna
`images[]` con 3 rutas a cada subasta en la BD).
Navbar: todas las vistas usan el widget compartido `AppNavBar` (estilo
moderno: gradiente oscuro, esquinas inferiores redondeadas y sombra) en
`lib/core/widgets/app_nav_bar.dart`.

Comandos verificados (ejecutar desde `subastas_app/`):
- `flutter pub get` — instala dependencias.
- `dart run build_runner build` — genera código de freezed/json_serializable.
- `flutter analyze` — análisis estático (sin issues).
- `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000` — arranque 
  contra backend local (emulador Android). En iOS simulador no hace falta 
  `--dart-define` (default `http://localhost:3000`).
- `flutter test` — tests unitarios (modelo Auction + BidsNotifier).
- `flutter test integration_test/catalog_images_test.dart -d <simulador-ios>` 
  — smoke test end-to-end en el simulador: inicia sesión con 
  `it_probe@example.com / probe1234` (registrada en la BD local), carga el 
  catálogo desde `GET /auctions?status=active` y verifica que las 22 
  imágenes del backend se descodifican (0 fallbacks).

Notas:
- Android: el manifest ya incluye `android:usesCleartextTraffic="true"` e 
  `INTERNET`; usar `API_BASE_URL=http://10.0.2.2:3000`.
- iOS: `Info.plist` incluye la excepción ATS (`NSAllowsArbitraryLoads` + 
  `NSAllowsLocalNetworking`) para HTTP en desarrollo. Cambios a 
  `Info.plist` requieren rebuild completo (no aplican con hot reload). En 
  dispositivo físico usar la IP LAN del Mac con 
  `--dart-define=API_BASE_URL=http://<IP>:3000`.
- No existe `/auth/me`: se persiste el user completo en secure storage 
  para restaurar la sesión al reabrir la app.

# Referencia cruzada

El backend vive en `../ProyectoBack/` y su propio AGENTS.md define el 
mismo contrato de eventos WebSocket y de API descrito aquí. Ambos 
archivos deben mantenerse sincronizados: cualquier cambio al contrato 
de eventos, roles, o modelo de datos debe reflejarse en los dos archivos 
en el mismo cambio.

# Contexto del proyecto

App de subastas en tiempo real (coches), cliente Flutter. Dos roles: 
`seller` (publica subastas) y `bidder` (puja). Plazo: 2 semanas. 
Prioridad: flujo funcional completo sobre pulido visual.

# Stack

- Flutter (null safety)
- Riverpod para manejo de estado
- dio para REST
- socket_io_client para WebSocket
- go_router para navegación
- freezed + json_serializable para modelos inmutables
- flutter_secure_storage para tokens

# Arquitectura de carpetas (feature-first)

lib/
  core/
    network/      -> ApiClient (dio) y SocketClient (socket_io_client)
    router/        -> configuración de go_router
    theme/
  features/
    auth/          -> login, registro, estado de sesión
    auctions/       
      data/         -> repositorios, DTOs
      domain/       -> modelos (freezed)
      presentation/ -> pantallas y providers de Riverpod
    bids/

# Backend / contrato de API

- Base URL configurable por entorno (dev/prod) en core/network.
- JWT se adjunta automáticamente vía interceptor de dio; se guarda en 
  flutter_secure_storage.
- Endpoints REST principales: /auth/login, /auth/register, /auctions, 
  /auctions/:id, /auctions/:id/bids (historial paginado).

Contrato de auth (debe coincidir con el backend):
- `POST /auth/register` body `{ email, password, name, role }` donde 
  `role` es `'seller' | 'bidder'` y es obligatorio. Respuesta 201: 
  `{ user: { id, email, name, role, created_at }, accessToken }`. 
  409 si el email ya existe; 400 si `password` < 8 chars o `role` inválido.
- `POST /auth/login` body `{ email, password }`. Respuesta 200:
  `{ user, accessToken }`. 401 si credenciales inválidas.
- `accessToken` es JWT con payload `{ userId, role }`; debe usarse como 
  `Authorization: Bearer <token>`.
- Endpoints fuera de `/auth` (salvo aquellos marcados públicos) devuelven 
  401 sin token y 403 si el rol del JWT no coincide.

# Contrato de eventos WebSocket (debe coincidir EXACTO con el backend)

Cliente -> Servidor:
- join_auction { auctionId }
- place_bid { auctionId, amount }

Servidor -> Cliente:
- auction_snapshot { auctionId, currentPrice, endTime, lastBids[], status }
- auction_error { message }
- new_bid { bidId, userId, userName, amount, createdAt }
- bid_rejected { reason, currentPrice }  (reason: 'amount_too_low' | 
  'auction_closed' | 'auction_not_active' | 'forbidden'; 'forbidden' es 
  rol distinto a bidder)
- time_extended { newEndTime }
- auction_closed { winnerId, winnerName, finalPrice }  (winnerId/winnerName 
  son null si la subasta cerró sin ofertas; status se mantiene 'closed', no 
  existe 'closed_no_bids'. Flutter muestra "sin ganador" cuando winnerId es null)
- auction_started { auctionId, currentPrice, endTime }  (broadcast global 
  a todos los clientes conectados; sirve para refrescar el catálogo en 
  vivo cuando una subasta pasa de 'scheduled' a 'active')

Conexión del WebSocket: el handshake debe incluir el JWT en `auth: { token }` 
(o header `Authorization: Bearer <token>`). Quien conecte sin token válido 
recibe connect_error 'Unauthorized'. Solo `bidder` puede emitir place_bid; 
el resto recibe bid_rejected reason 'forbidden'.

Reglas de implementación:
- endTime es timestamp absoluto UTC. El cliente calcula localmente 
  (endTime - now()) y corre un Timer.periodic solo para actualizar UI 
  cada segundo. Siempre resincroniza si llega time_extended o un nuevo 
  auction_snapshot.
- Al reconectar el socket (pérdida de red), volver a emitir join_auction 
  y refrescar todo el estado desde auction_snapshot — nunca asumir que 
  no se perdió ningún evento.
- El cliente nunca decide localmente quién ganó ni valida montos: solo 
  refleja lo que el servidor emite.

# Navegación por rol

- Tras login, redirect según role del usuario (guardado en el estado 
  de auth): 'seller' -> flujo de publicación, 'bidder' -> flujo de catálogo.
- Usar redirect de go_router basado en un provider de Riverpod con el 
  estado de auth, no lógica dispersa en cada pantalla.

# Convenciones de código

- Modelos inmutables con freezed, un archivo por modelo.
- Un provider de Riverpod por feature/pantalla, evitar lógica de negocio 
  en los widgets.
- Nombres de archivos: snake_case. Clases: PascalCase.
- No usar StatefulWidget para estado que pertenece al dominio (usar Riverpod).

# UX mínima esperada (no simplificar estos estados)

- Loading / error / vacío en cada pantalla que consuma datos.
- Indicador visual de conexión del WebSocket (conectado/reconectando) 
  en la pantalla de detalle de subasta.
- Feedback inmediato (sin esperar respuesta del server) al presionar 
  "pujar", pero corregir con lo que confirme el servidor.

# Qué NO hacer

- No agregar paquetes nuevos sin que estén en este archivo o se pida 
  explícitamente.
- No implementar lógica de countdown que ignore resincronización del server.
- No cambiar el contrato de eventos sin señalarlo explícitamente (afecta 
  al backend NestJS).