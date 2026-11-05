import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/app/router/app_routes.dart';
import 'package:geops_mobile/app/router/auth_redirect.dart';
import 'package:geops_mobile/features/auth/domain/entities/user.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  const loading = AsyncLoading<User?>();
  const signedOut = AsyncData<User?>(null);
  const consumer = AsyncData<User?>(testConsumer);
  const provider = AsyncData<User?>(testProvider);

  test('while restoring the session or offline on start, everything goes to splash', () {
    expect(authRedirect(loading, AppRoutes.home), AppRoutes.splash);
    expect(authRedirect(AsyncError<User?>(Exception(), StackTrace.empty), AppRoutes.login), AppRoutes.splash);
    expect(authRedirect(loading, AppRoutes.splash), isNull);
  });

  test('signed-out users only reach login and register', () {
    expect(authRedirect(signedOut, AppRoutes.splash), AppRoutes.login);
    expect(authRedirect(signedOut, AppRoutes.home), AppRoutes.login);
    expect(authRedirect(signedOut, AppRoutes.business), AppRoutes.login);
    expect(authRedirect(signedOut, AppRoutes.login), isNull);
    expect(authRedirect(signedOut, AppRoutes.register), isNull);
  });

  test('each role lands on its own home and cannot open the other one', () {
    expect(authRedirect(consumer, AppRoutes.login), AppRoutes.home);
    expect(authRedirect(consumer, AppRoutes.business), AppRoutes.home);
    expect(authRedirect(consumer, AppRoutes.home), isNull);

    expect(authRedirect(provider, AppRoutes.splash), AppRoutes.business);
    expect(authRedirect(provider, AppRoutes.home), AppRoutes.business);
    expect(authRedirect(provider, AppRoutes.business), isNull);
  });
}
