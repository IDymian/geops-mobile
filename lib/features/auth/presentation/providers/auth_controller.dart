import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/auth_providers.dart';
import '../../domain/entities/user.dart';

/// Current session: `AsyncData(user)` when signed in, `AsyncData(null)` when not,
/// `AsyncLoading` while restoring it on start, `AsyncError` if that failed offline.
///
/// Login and register errors are thrown to the calling form instead of being
/// stored here, so a wrong password never looks like a lost session.
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final subscription = ref.watch(sessionExpiredProvider).stream.listen((_) => state = const AsyncData(null));
    ref.onDispose(subscription.cancel);
    return ref.watch(authRepositoryProvider).restoreSession();
  }

  Future<void> login({required String email, required String password}) async {
    final user = await ref.read(authRepositoryProvider).login(email: email, password: password);
    state = AsyncData(user);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .register(email: email, password: password, fullName: fullName, role: role);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  /// Tries to restore the session again (after being offline on start).
  void retry() => ref.invalidateSelf();
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(AuthController.new);
