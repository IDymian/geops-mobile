import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/widgets/logout_button.dart';

/// Provider home. Placeholder until the business panel lands (Day 2).
class BusinessHomePage extends ConsumerWidget {
  const BusinessHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi negocio'), actions: const [LogoutButton()]),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, size: 56),
            const SizedBox(height: 16),
            Text('Hola, ${user?.fullName ?? ''}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Pronto podrás publicar ofertas y cupones aquí.'),
          ],
        ),
      ),
    );
  }
}
