import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/env.dart';

/// Shared HTTP client for the GeoPS API.
///
/// Feature interceptors (auth token, refresh) are added where they are defined.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  if (kDebugMode) {
    // Never log bodies or headers: they carry passwords and tokens.
    dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false, requestHeader: false));
  }

  ref.onDispose(dio.close);
  return dio;
});
