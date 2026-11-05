import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Cerrar sesión',
      icon: const Icon(Icons.logout),
      onPressed: () => ref.read(authControllerProvider.notifier).logout(),
    );
  }
}
