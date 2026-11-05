# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [0.2.0] - 2026-11-05

Second sprint (Day 2 of the MVP): offers near the user and the business panel.

### Added

- Offers near the consumer, on a Google Map (their position, the search radius and one marker per offer) or as a list with distance, price in soles, discount and expiry.
- Filters by category and radius (500 m to 10 km), pull to refresh, and an offer detail page with the business.
- Location only while the app is in use, asked after a screen that explains why; a blocked permission points to the settings and a disabled GPS asks to turn it on.
- Business panel for providers: register or edit the business, set its location from the device or with a pin on a map.
- Offer management: publish and edit offers, see each one's status (live, scheduled, paused, expired) and pause or reactivate it with a switch.
- Native Google Maps configuration that reads the key from `android/local.properties` or `ios/Flutter/Secrets.xcconfig` (both ignored by Git).

### Changed

- CI uses `actions/setup-java` v6.

### Removed

- Unused `cupertino_icons` dependency.

## [0.1.0] - 2026-11-04

First sprint (Day 1 of the MVP): app foundation and authentication.

### Added

- Flutter 3.47 / Dart 3.13 app for Android and iOS, with Clean Architecture per feature (presentation / domain / data), Riverpod, go_router, Dio and freezed.
- Sign up as a consumer ("Busco ofertas") or a business ("Tengo un negocio"), sign in and sign out, with Spanish UI and validation that mirrors the API rules.
- Session restored on app start; offline start offers a retry instead of signing out.
- Tokens stored only in secure storage (Android Keystore / iOS Keychain).
- HTTP client that attaches the access token and refreshes it once on a 401 (a single refresh for concurrent requests); an expired session returns to login.
- Role-based navigation: consumers and businesses land on their own home and cannot open the other one.
- Typed error handling (`Failure`) mapped from the API's problem-details responses.
- Compile-time configuration with `--dart-define-from-file` (no bundled `.env`).
- CI on GitHub Actions (format, analyze, tests, debug APK) and Dependabot.
- Nightly backup scripts to the `wip/nightly` branch.

[0.2.0]: https://github.com/geops-app/geops-mobile/releases/tag/v0.2.0
[0.1.0]: https://github.com/geops-app/geops-mobile/releases/tag/v0.1.0
