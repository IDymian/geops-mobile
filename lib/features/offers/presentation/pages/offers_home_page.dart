import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/widgets/logout_button.dart';

/// Consumer home. Placeholder until the offers map lands (Day 2).
class OffersHomePage extends ConsumerWidget {
  const OffersHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas cerca de ti'), actions: const [LogoutButton()]),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 56),
            const SizedBox(height: 16),
            Text('Hola, ${user?.fullName ?? ''}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Pronto verás aquí las ofertas de tu zona.'),
          ],
        ),
      ),
    );
  }
}
