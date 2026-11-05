import 'package:geops_mobile/core/errors/failure.dart';
import 'package:geops_mobile/features/auth/domain/entities/user.dart';
import 'package:geops_mobile/features/auth/domain/repositories/auth_repository.dart';

const testConsumer = User(id: 'u-1', email: 'ana@example.com', fullName: 'Ana Torres', role: UserRole.consumer);
const testProvider = User(id: 'u-2', email: 'bodega@example.com', fullName: 'Bodega Lucho', role: UserRole.provider);

/// In-memory [AuthRepository] for widget tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.restoredUser, this.loginResult, this.loginFailure});

  User? restoredUser;
  User? loginResult;
  Failure? loginFailure;
  final List<String> calls = [];

  @override
  Future<User?> restoreSession() async => restoredUser;

  @override
  Future<User> login({required String email, required String password}) async {
    calls.add('login:$email');
    if (loginFailure != null) throw loginFailure!;
    return loginResult ?? testConsumer;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    calls.add('register:$email:${role.name}');
    return User(id: 'new', email: email, fullName: fullName, role: role);
  }

  @override
  Future<void> logout() async => calls.add('logout');
}
