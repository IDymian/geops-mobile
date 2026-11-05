import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Adds the access token to API calls and, when the API answers 401 because the
/// token expired, refreshes it once and retries the original request.
///
/// It is a [QueuedInterceptor]: requests wait while a refresh is in progress,
/// so several 401s at once trigger a single refresh, not one per request.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this._tokenStorage,
    required this._refreshClient,
    required this._retryClient,
    required this._onSessionExpired,
  });

  static const _retriedFlag = 'auth_retried';

  final TokenStorage _tokenStorage;

  /// Plain client without this interceptor, used only for `/auth/refresh`.
  final Dio _refreshClient;

  /// Client without this interceptor, used to replay the original request after a refresh.
  final Dio _retryClient;
  final void Function() _onSessionExpired;

  static bool _isAuthEndpoint(RequestOptions options) => options.path.startsWith('/auth/');

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isAuthEndpoint(options)) {
      final tokens = await _tokenStorage.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    if (!isUnauthorized || _isAuthEndpoint(request) || request.extra[_retriedFlag] == true) {
      return handler.next(err);
    }

    final stored = await _tokenStorage.read();
    if (stored == null) return handler.next(err);

    // Another queued request may have refreshed already: just retry with the new token.
    final sentToken = request.headers['Authorization'];
    final tokens = sentToken == 'Bearer ${stored.accessToken}' ? await _refresh(stored.refreshToken) : stored;
    if (tokens == null) {
      await _tokenStorage.clear();
      _onSessionExpired();
      return handler.next(err);
    }

    try {
      final retry = request.copyWith(
        headers: {...request.headers, 'Authorization': 'Bearer ${tokens.accessToken}'},
        extra: {...request.extra, _retriedFlag: true},
      );
      handler.resolve(await _retryClient.fetch<Object?>(retry));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<TokenPair?> _refresh(String refreshToken) async {
    try {
      final response = await _refreshClient.post<Map<String, Object?>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final body = response.data;
      final access = body?['accessToken'];
      final refresh = body?['refreshToken'];
      if (access is! String || refresh is! String) return null;
      final tokens = TokenPair(accessToken: access, refreshToken: refresh);
      await _tokenStorage.save(tokens);
      return tokens;
    } on DioException {
      return null;
    }
  }
}
