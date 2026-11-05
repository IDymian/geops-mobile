import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/app/app.dart';
import 'package:geops_mobile/core/errors/failure.dart';
import 'package:geops_mobile/features/auth/data/auth_providers.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  Future<FakeAuthRepository> pumpApp(WidgetTester tester, FakeAuthRepository repository) async {
    await tester.pumpWidget(
      ProviderScope(overrides: [authRepositoryProvider.overrideWithValue(repository)], child: const GeopsApp()),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('without a session the app opens on the login page', (tester) async {
    await pumpApp(tester, FakeAuthRepository());

    expect(find.text('Bienvenido a GeoPS'), findsOneWidget);
  });

  testWidgets('a restored provider session opens the business home', (tester) async {
    await pumpApp(tester, FakeAuthRepository(restoredUser: testProvider));

    expect(find.text('Mi negocio'), findsOneWidget);
  });

  testWidgets('shows validation errors and does not call the API', (tester) async {
    final repository = await pumpApp(tester, FakeAuthRepository());

    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(repository.calls, isEmpty);
  });

  testWidgets('wrong credentials show a message and stay on the login page', (tester) async {
    await pumpApp(
      tester,
      FakeAuthRepository(
        loginFailure: const ApiFailure(statusCode: 401, code: 'AUTH_INVALID_CREDENTIALS', message: 'Invalid'),
      ),
    );

    await tester.enterText(find.byKey(const Key('login.email')), 'ana@example.com');
    await tester.enterText(find.byKey(const Key('login.password')), 'Wrong12345');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.text('Bienvenido a GeoPS'), findsOneWidget);
  });

  testWidgets('a successful consumer login opens the offers home, and logout returns to login', (tester) async {
    final repository = await pumpApp(tester, FakeAuthRepository(loginResult: testConsumer));

    await tester.enterText(find.byKey(const Key('login.email')), 'ana@example.com');
    await tester.enterText(find.byKey(const Key('login.password')), 'Secreta123');
    await tester.tap(find.byKey(const Key('login.submit')));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Ana Torres'), findsOneWidget);
    expect(repository.calls, ['login:ana@example.com']);

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a GeoPS'), findsOneWidget);
    expect(repository.calls.last, 'logout');
  });

  testWidgets('registering as a business opens the business home', (tester) async {
    final repository = await pumpApp(tester, FakeAuthRepository());

    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tengo un negocio'));
    await tester.enterText(find.byKey(const Key('register.fullName')), 'Bodega Lucho');
    await tester.enterText(find.byKey(const Key('register.email')), 'bodega@example.com');
    await tester.enterText(find.byKey(const Key('register.password')), 'Secreta123');
    await tester.ensureVisible(find.byKey(const Key('register.submit')));
    await tester.tap(find.byKey(const Key('register.submit')));
    await tester.pumpAndSettle();

    expect(repository.calls, ['register:bodega@example.com:provider']);
    expect(find.text('Mi negocio'), findsOneWidget);
  });
}
