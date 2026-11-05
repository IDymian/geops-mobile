import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/env.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

BaseOptions _baseOptions() => BaseOptions(
  baseUrl: Env.apiBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
  contentType: Headers.jsonContentType,
  responseType: ResponseType.json,
);

/// Emits when the session can no longer be refreshed (refresh token expired or revoked).
/// The auth feature listens to it and sends the user back to the login screen.
final sessionExpiredProvider = Provider<StreamController<void>>((ref) {
  final controller = StreamController<void>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

/// Shared HTTP client for the GeoPS API, with the access token attached automatically.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions());
  // Without the auth interceptor: replaying through `dio` from inside a queued
  // interceptor could deadlock if the retry failed too.
  final plainClient = Dio(_baseOptions());

  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: ref.watch(tokenStorageProvider),
      refreshClient: plainClient,
      retryClient: plainClient,
      onSessionExpired: () => ref.read(sessionExpiredProvider).add(null),
    ),
  );

  if (kDebugMode) {
    // Never log bodies or headers: they carry passwords and tokens.
    dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false, requestHeader: false));
  }

  ref.onDispose(() {
    dio.close();
    plainClient.close();
  });
  return dio;
});
