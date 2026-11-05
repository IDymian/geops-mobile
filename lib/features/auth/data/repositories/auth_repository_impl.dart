import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  /// Exchanges the stored refresh token for a fresh session, which also
  /// confirms the account still exists and returns the up-to-date profile.
  @override
  Future<User?> restoreSession() async {
    final stored = await _tokenStorage.read();
    if (stored == null) return null;
    try {
      return await _startSession(await _remote.refresh(stored.refreshToken));
    } catch (error) {
      final failure = mapError(error);
      if (failure is NetworkFailure) throw failure;
      // Token expired, revoked or reused: the user must sign in again.
      await _tokenStorage.clear();
      return null;
    }
  }

  @override
  Future<User> login({required String email, required String password}) =>
      _guard(() async => _startSession(await _remote.login(email: email.trim(), password: password)));

  @override
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) => _guard(
    () async => _startSession(
      await _remote.register(
        email: email.trim(),
        password: password,
        fullName: fullName.trim(),
        role: UserRoleModel.fromEntity(role),
      ),
    ),
  );

  /// Always clears the local session, even if the server cannot be reached.
  @override
  Future<void> logout() async {
    final stored = await _tokenStorage.read();
    await _tokenStorage.clear();
    if (stored == null) return;
    try {
      await _remote.logout(stored.refreshToken);
    } catch (_) {
      // Best effort: the refresh token expires on its own.
    }
  }

  Future<User> _startSession(AuthResponseModel response) async {
    await _tokenStorage.save(TokenPair(accessToken: response.accessToken, refreshToken: response.refreshToken));
    return response.user.toEntity();
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw mapError(error);
    }
  }
}
