import 'package:dio/dio.dart';

import '../models/auth_response_model.dart';

/// Calls the `/auth` endpoints of the GeoPS API.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthResponseModel> login({required String email, required String password}) =>
      _post('/auth/login', {'email': email, 'password': password});

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    required UserRoleModel role,
  }) => _post('/auth/register', {'email': email, 'password': password, 'fullName': fullName, 'role': role.apiValue});

  Future<AuthResponseModel> refresh(String refreshToken) => _post('/auth/refresh', {'refreshToken': refreshToken});

  Future<void> logout(String refreshToken) => _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});

  Future<AuthResponseModel> _post(String path, Map<String, Object?> body) async {
    final response = await _dio.post<Map<String, Object?>>(path, data: body);
    return AuthResponseModel.fromJson(response.data!);
  }
}
