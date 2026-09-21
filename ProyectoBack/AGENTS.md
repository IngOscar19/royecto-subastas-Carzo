# Estado actual

Proyecto NestJS `subastas-backend` escafoldeado en la raíz de 
`ProyectoBack/` (TypeScript, NestJS 11). Módulos esqueleto: auth, users, 
auctions, bids, notifications, redis. Entidades TypeORM creadas 
(`user.entity.ts`, `auction.entity.ts`, `bid.entity.ts`) con migración 
`CreateUsersAuctionsBids` ya aplicada (uuid PKs, enums nativos, decimales 
con transformer a number, índice `(auction_id, created_at DESC)`, FKs).

Comandos verificados:
- `npm run start:dev` — arranque en watch.
- `npm run build` — compila a `dist/`.
- `npm run lint` — ESLint.
- `npm test` — Jest (unit).
- `npm run typeorm -- migration:show` — CLI de migraciones (DataSource en `src/database/data-source.ts`).
- `npm run migration:run` / `npm run migration:revert` — aplicar/revertir migraciones.
- `docker compose up -d` — Postgres 16 + Redis 7 locales (puertos 5432/6379).

La sección inferior de este archivo sigue siendo la spec de diseño 
objetivo: módulos, entidades, endpoints y contrato de eventos se 
implementan por fases. No asumas que las entidades o endpoints descritos 
más abajo ya existen.

Auth JWT ya implementado: `POST /auth/register` (requiere `role`) y 
`POST /auth/login`; payload del JWT `{ userId, role }` (bcryptjs para 
hash, stack Passport). Guards globales: `JwtAuthGuard` (valida Bearer, 
respeta `@Public()`) y `RolesGuard` (permite si `@Roles()` no está, sino 
exige el rol del JWT -> 403). Decoradores en `src/common/`:
`@Public()`, `@Roles(UserRole.SELLER | UserRole.BIDDER)`.

Cierre/activación automática de subastas ya implementado: 
`src/auctions/auctions.scheduler.ts` corre con `@nestjs/schedule` cada 5s; 
cierra subastas `active` con `end_time` vencido (lock pesimista + último 
bid como ganador, emite `auction_closed`) y activa subastas `scheduled` 
cuyo `start_time` llegó (emite `auction_started` en broadcast global).

Imágenes de vehículos: `main.ts` sirve estáticos desde `public/` con
NestExpressApplication (`useStaticAssets`). El catálogo tiene 22 subastas
activas de vehículos (sedanes, pick-ups, SUVs, eléctricos y deportivos)
con `images[]` de hasta 3 rutas por vehículo
(`/images/auctions/<slug>.jpg`, `<slug>-2.jpg`, `<slug>-3.jpg`; 66 archivos
en total). Los scripts en `scripts/` descargan hasta 3 imágenes por
vehículo (Wikipedia/Commons con overrides curados para vehículos concretos;
`fetch-auction-images.mjs` soporta `--offline`) y las asignan a la BD con
`attach-images.mjs`.

# Referencia cruzada

El cliente Flutter vive en `../FrontFlutter/` y su propio AGENTS.md 
replica el mismo contrato de eventos WebSocket y de API descrito aquí. 
Ambos archivos deben mantenerse sincronizados: cualquier cambio al 
contrato de eventos, roles, o modelo de datos debe reflejarse en los 
dos archivos en el mismo cambio.

# Contexto del proyecto

App de subastas en tiempo real (coches). Dos roles de usuario: `seller` 
(publica subastas) y `bidder` (puja). Plazo del proyecto: 2 semanas. 
Prioridad: funcionalidad end-to-end sobre features extra. No sobre-ingenierizar.

# Stack

- NestJS + TypeScript
- PostgreSQL con TypeORM (migraciones, no synchronize en ningún ambiente)
- Redis (ioredis) para estado caliente de subastas activas y pub/sub
- Socket.IO para WebSocket
- BullMQ para colas (notificaciones)
- @nestjs/schedule para cron jobs (cierre/activación automática de subastas)
- class-validator / class-transformer para DTOs
- @nestjs/jwt + @nestjs/passport + passport-jwt para JWT
- bcryptjs para hash de contraseñas

# Estructura de carpetas

src/
  auth/        -> registro, login, JWT, guards de rol
  users/
  auctions/    -> CRUD REST + AuctionsGateway (WebSocket)
  bids/        -> lógica de validación y persistencia de ofertas
  notifications/ -> productor/worker de BullMQ + integración FCM
  redis/       -> módulo compartido de conexión a Redis
  common/      -> decoradores, guards, pipes compartidos

# Modelo de datos (fuente de verdad, no cambiar sin avisar)

- User: id, email, password_hash, name, role ('seller'|'bidder'), created_at
- Auction: id, seller_id, title, description, images, starting_price, 
  current_price, min_increment, start_time, end_time, 
  status ('scheduled'|'active'|'closed'), winner_id, created_at
- Bid: id, auction_id, user_id, amount, created_at
  (índice compuesto en auction_id + created_at DESC)

# Roles y permisos

- Solo `seller` puede: crear, editar y cancelar subastas propias.
- Solo `bidder` puede: pujar.
- Usa el decorador @Roles() + RolesGuard para proteger endpoints. 
  Nunca confíes en el rol enviado desde el cliente; siempre desde el JWT.

# Contrato de eventos WebSocket (NO renombrar sin actualizar Flutter también)

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
- auction_closed { winnerId, winnerName, finalPrice }
- auction_started { auctionId, currentPrice, endTime }  (broadcast global 
  a todos los clientes conectados; sirve para refrescar el catálogo en 
  vivo cuando una subasta pasa de 'scheduled' a 'active')

Conexión del WebSocket: el handshake debe incluir el JWT en 
`auth: { token }` (o header `Authorization: Bearer <token>`). El servidor 
lo verifica; quien conecte sin token válido es rechazado con connect_error 
'y Unauthorized'. Solo `bidder` puede emitir place_bid; el resto recibe 
bid_rejected reason 'forbidden'.

Reglas:
- endTime siempre es timestamp absoluto UTC (epoch ms), nunca "segundos restantes".
- Cada subasta es una room de Socket.IO identificada por auctionId.

# Reglas de concurrencia (crítico, no simplificar sin aviso)

- Toda oferta se valida y persiste dentro de una transacción o lock 
  (SELECT FOR UPDATE en Postgres como mínimo aceptable; Redis+Redlock 
  si hay tiempo).
- Nunca proceses dos ofertas de la misma subasta en paralelo.
- El servidor es la única fuente de verdad del tiempo y del precio actual, 
  nunca el cliente.

# Convenciones de código

- DTOs con class-validator en cada endpoint, nunca confiar en el body crudo.
- Servicios no acceden a la request directamente; los controllers/gateways sí.
- Nombres de archivos: kebab-case. Clases: PascalCase.
- Variables de entorno en .env, nunca hardcodear credenciales.
- Cada cambio de esquema va acompañado de su migración (no editar 
  migraciones ya aplicadas).

# Testing

- Priorizar tests de la lógica de bids (validación de monto, rechazo, 
  anti-sniping) sobre cobertura general, dado el plazo.

# Qué NO hacer

- No agregar librerías o dependencias nuevas sin que estén en este archivo 
  o se pida explícitamente.
- No cambiar el contrato de eventos WebSocket sin señalarlo explícitamente 
  en la respuesta (afecta al cliente Flutter).
- No usar `synchronize: true` de TypeORM en ningún ambiente.