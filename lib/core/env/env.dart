/// Compile-time configuration passed with `--dart-define-from-file=.env`.
///
/// Only public values belong here: everything is readable inside the binary.
abstract final class Env {
  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  /// Android emulator reaches the host machine at 10.0.2.2.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8080/api/v1');

  static bool get isProduction => appEnv == 'prod';
}
