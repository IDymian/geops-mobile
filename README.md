# GeoPS Mobile

> 🇪🇸 [Español](#español) · 🇬🇧 [English](#english)

[![CI](https://github.com/geops-app/geops-mobile/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/geops-app/geops-mobile/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/geops-app/geops-mobile)](https://github.com/geops-app/geops-mobile/releases)
![Flutter](https://img.shields.io/badge/Flutter-Dart%203-02569B)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## Español

**GeoPS Mobile** conecta negocios locales con consumidores mediante ofertas y cupones hiperlocales según su ubicación. Es la versión móvil de un proyecto web universitario y consume la API [geops-api](https://github.com/geops-app/geops-api).

**Estado:** MVP completo (`v0.3.x`). Cambios por versión en el [CHANGELOG](CHANGELOG.md).

### Funcionalidades

- **Cuentas:** registro como consumidor o negocio, login y sesión que se renueva sola, con los tokens en almacenamiento seguro.
- **Consumidor:**
  - Ofertas cercanas en un mapa de Google o en lista, con distancia, precio en soles y descuento.
  - Filtros por categoría y radio (500 m a 10 km).
  - Detalle de la oferta con sus cupones: se obtienen con un toque.
  - "Mis cupones": cada código como QR y en texto (`K7QM-4XPA`), con su estado.
- **Negocio:**
  - Perfil del negocio y su ubicación, desde el GPS o con un pin en el mapa.
  - Publicar, editar y pausar ofertas, y crear cupones para cada una.
  - Canjear cupones en caja escribiendo el código: la app dice cuánto cobrar.
  - Estadísticas: tasa de canje, mejores ofertas y un gráfico de los últimos 7 días.
- **Privacidad:** la ubicación se pide con una pantalla que explica para qué y solo se usa con la app abierta.

**Próximamente:** escanear el QR con la cámara, favoritos, reseñas, carrito, suscripción a negocios, pagos y notificaciones.

### Stack

| Área | Tecnología |
|---|---|
| Lenguaje | Dart 3 / Flutter |
| Estado | Riverpod 3 |
| Navegación | go_router |
| Red | Dio, con interceptor que renueva el token |
| Modelos | freezed + json_serializable |
| Almacenamiento seguro | flutter_secure_storage |
| Mapas y ubicación | google_maps_flutter, geolocator |
| Códigos QR | qr_flutter |
| Pruebas | flutter_test (unitarias, de widgets y de flujos) + mocktail |

### Arquitectura

Clean Architecture por funcionalidad: `auth`, `offers`, `coupons` y `business` en `lib/features/`, cada una con las capas `presentation`, `domain` y `data`. Lo compartido (red, almacenamiento seguro, ubicación, errores, utilidades) vive en `lib/core/`.

### Cómo ejecutar

```bash
cp .env.example .env   # completa los valores públicos
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define-from-file=.env
```

- La configuración se pasa con `--dart-define-from-file` en lugar de empaquetar un `.env` como asset, que quedaría expuesto dentro del APK.
- Por defecto la app apunta a `http://10.0.2.2:8080/api/v1`, la API corriendo en tu PC vista desde el emulador de Android. Para usar la API desplegada, cambia `API_BASE_URL` en `.env`.
- Para ver el mapa, pon tu clave de Google Maps en `android/local.properties` (`MAPS_API_KEY=...`), que Git ignora.

Pruebas: `flutter test`

### Flujo de trabajo con Git

- `main`: versión estable. Solo recibe `develop` en cada release, con un tag semántico (`v0.1.0`, `v0.2.0`…).
- `develop`: integración. Cada funcionalidad llega mediante pull request desde una rama `feature/*`, con CI obligatorio.
- `wip/nightly`: **solo es un respaldo automático nocturno** de trabajo sin terminar. La historia real del proyecto está en las ramas `feature/*` y en sus pull requests. Detalles: [docs/nightly-backup.md](docs/nightly-backup.md).

### Licencia

[MIT](LICENSE)

---

## English

**GeoPS Mobile** connects local businesses with consumers through hyperlocal, location-based offers and coupons. It is the mobile version of a university web project and consumes the [geops-api](https://github.com/geops-app/geops-api) backend.

**Status:** MVP complete (`v0.3.x`). Changes per version in the [CHANGELOG](CHANGELOG.md).

### Features

- **Accounts:** sign up as a consumer or a business, login and a session that renews itself, with tokens in secure storage.
- **Consumer:**
  - Nearby offers on a Google Map or as a list, with distance, price in soles and discount.
  - Category and radius filters (500 m to 10 km).
  - Offer details with their coupons, claimed in one tap.
  - "My coupons": each code as a QR and as text (`K7QM-4XPA`), with its status.
- **Business:**
  - Business profile and location, from GPS or with a pin on the map.
  - Publish, edit and pause offers, and issue coupons for each one.
  - Redeem coupons at the counter by typing the code: the app says how much to charge.
  - Stats: redemption rate, top offers and a chart of the last 7 days.
- **Privacy:** location is requested after a screen that explains why, and used only while the app is open.

**Coming next:** QR scanning with the camera, favorites, reviews, cart, business subscriptions, payments and notifications.

### Tech stack

| Area | Technology |
|---|---|
| Language | Dart 3 / Flutter |
| State | Riverpod 3 |
| Navigation | go_router |
| Networking | Dio, with an interceptor that refreshes the token |
| Models | freezed + json_serializable |
| Secure storage | flutter_secure_storage |
| Maps & location | google_maps_flutter, geolocator |
| QR codes | qr_flutter |
| Testing | flutter_test (unit, widget and flow tests) + mocktail |

### Architecture

Feature-first Clean Architecture: `auth`, `offers`, `coupons` and `business` in `lib/features/`, each with `presentation`, `domain` and `data` layers. Shared code (networking, secure storage, location, errors, utilities) lives in `lib/core/`.

### Getting started

```bash
cp .env.example .env   # fill in the public values
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define-from-file=.env
```

- Configuration is passed with `--dart-define-from-file` instead of bundling a `.env` asset, which would be readable inside the APK.
- By default the app points to `http://10.0.2.2:8080/api/v1`, the API running on your computer as seen from the Android emulator. To use the deployed API, change `API_BASE_URL` in `.env`.
- To see the map, put your Google Maps key in `android/local.properties` (`MAPS_API_KEY=...`), which Git ignores.

Tests: `flutter test`

### Git workflow

- `main`: stable. Receives `develop` only on each release, with a semantic tag (`v0.1.0`, `v0.2.0`…).
- `develop`: integration. Every feature arrives through a pull request from a `feature/*` branch, with required CI.
- `wip/nightly`: **only an automatic nightly backup** of unfinished work. The real project history lives in the `feature/*` branches and their pull requests. Details: [docs/nightly-backup.md](docs/nightly-backup.md).

### License

[MIT](LICENSE)
