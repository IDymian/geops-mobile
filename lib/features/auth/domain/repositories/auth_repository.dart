import '../entities/user.dart';

/// Authentication contract used by the presentation layer.
///
/// Implementations throw a `Failure` (see `core/errors`) when something goes wrong.
abstract interface class AuthRepository {
  /// Restores the previous session on app start, or returns `null` if there is none.
  Future<User?> restoreSession();

  Future<User> login({required String email, required String password});

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  Future<void> logout();
}
