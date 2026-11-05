# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

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

[0.1.0]: https://github.com/geops-app/geops-mobile/releases/tag/v0.1.0
