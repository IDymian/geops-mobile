# GeoPS Mobile

> 🇪🇸 [Español](#español) · 🇬🇧 [English](#english)

![Status](https://img.shields.io/badge/status-in%20development-orange)
![Flutter](https://img.shields.io/badge/Flutter-Dart%203-02569B)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## Español

**GeoPS Mobile** conecta negocios locales con consumidores mediante ofertas y cupones hiperlocales según su ubicación. Es la versión móvil de un proyecto web universitario y consume la API [geops-api](https://github.com/IDymian/geops-api).

### Funcionalidades

- **Consumidor:** mapa con ofertas cercanas, filtros por categoría y distancia, favoritos, reseñas, carrito, canje de cupones, suscripción a negocios y pago.
- **Proveedor:** crea y edita ofertas y cupones, gestiona el perfil de su negocio y ve estadísticas de canjes.
- **Privacidad:** la ubicación se pide con permiso explícito y solo se usa con la app en primer plano.

### Stack

| Área | Tecnología |
|---|---|
| Lenguaje | Dart 3 / Flutter |
| Estado | Riverpod |
| Navegación | go_router |
| Red | Dio |
| Modelos | freezed + json_serializable |
| Almacenamiento seguro | flutter_secure_storage |
| Mapas y ubicación | google_maps_flutter, geolocator |
| Notificaciones | firebase_messaging |
| Biometría | local_auth |

### Arquitectura

Clean Architecture por funcionalidad: cada carpeta de `lib/features/` tiene las capas `presentation`, `domain` y `data`. Lo compartido (red, almacenamiento seguro, ubicación, errores) vive en `lib/core/`.

### Cómo ejecutar

> 🚧 En construcción. Se completará en el primer sprint.

```bash
cp .env.example .env   # completa los valores públicos
flutter pub get
flutter run --dart-define-from-file=.env
```

La configuración se pasa con `--dart-define-from-file` en lugar de empaquetar un `.env` como asset, que quedaría expuesto dentro del APK.

### Flujo de trabajo con Git

- `main`: versión estable. Solo recibe `develop` al cerrar cada sprint, con un tag semántico (`v0.1.0`, `v0.2.0`…).
- `develop`: integración. Cada funcionalidad llega mediante pull request desde una rama `feature/*`.
- `wip/nightly`: **solo es un respaldo automático nocturno** de trabajo sin terminar. La historia real del proyecto está en las ramas `feature/*` y en sus pull requests. Detalles: [docs/nightly-backup.md](docs/nightly-backup.md).

### Licencia

[MIT](LICENSE)

---

## English

**GeoPS Mobile** connects local businesses with consumers through hyperlocal, location-based offers and coupons. It is the mobile version of a university web project and consumes the [geops-api](https://github.com/IDymian/geops-api) backend.

### Features

- **Consumer:** map of nearby offers, category and distance filters, favorites, reviews, cart, coupon redemption, business subscriptions and payment.
- **Provider:** create and edit offers and coupons, manage the business profile and view redemption stats.
- **Privacy:** location is requested with explicit permission and used only while the app is in the foreground.

### Tech stack

| Area | Technology |
|---|---|
| Language | Dart 3 / Flutter |
| State | Riverpod |
| Navigation | go_router |
| Networking | Dio |
| Models | freezed + json_serializable |
| Secure storage | flutter_secure_storage |
| Maps & location | google_maps_flutter, geolocator |
| Notifications | firebase_messaging |
| Biometrics | local_auth |

### Architecture

Feature-first Clean Architecture: each folder in `lib/features/` has `presentation`, `domain` and `data` layers. Shared code (networking, secure storage, location, errors) lives in `lib/core/`.

### Getting started

> 🚧 Work in progress. Completed in the first sprint.

```bash
cp .env.example .env   # fill in the public values
flutter pub get
flutter run --dart-define-from-file=.env
```

Configuration is passed with `--dart-define-from-file` instead of bundling a `.env` asset, which would be readable inside the APK.

### Git workflow

- `main`: stable. Receives `develop` only at the end of each sprint, with a semantic tag (`v0.1.0`, `v0.2.0`…).
- `develop`: integration. Every feature arrives through a pull request from a `feature/*` branch.
- `wip/nightly`: **only an automatic nightly backup** of unfinished work. The real project history lives in the `feature/*` branches and their pull requests. Details: [docs/nightly-backup.md](docs/nightly-backup.md).

### License

[MIT](LICENSE)
