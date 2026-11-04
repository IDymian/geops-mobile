import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route paths in one place, so screens never hard-code strings.
abstract final class AppRoutes {
  static const String home = '/';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [GoRoute(path: AppRoutes.home, builder: (context, state) => const _WelcomePage())],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Temporary landing page until the auth feature adds the real flow.
class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('GeoPS', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Ofertas cerca de ti'),
          ],
        ),
      ),
    );
  }
}
