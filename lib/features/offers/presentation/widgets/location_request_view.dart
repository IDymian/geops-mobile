import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/location/location_service.dart';
import '../providers/offers_providers.dart';

/// Explains why GeoPS needs the location before the system dialog appears,
/// and guides the user when access was denied or the GPS is off.
class LocationRequestView extends ConsumerWidget {
  const LocationRequestView({super.key, required this.access});

  final LocationAccess access;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(locationServiceProvider);
    final controller = ref.read(locationProvider.notifier);

    final (icon, title, body, action, onPressed) = switch (access) {
      LocationAccess.serviceDisabled => (
        Icons.location_off_outlined,
        'Tu ubicación está desactivada',
        'Actívala para ver las ofertas que tienes cerca.',
        'Activar ubicación',
        () async {
          await service.openLocationSettings();
          await controller.refresh();
        },
      ),
      LocationAccess.deniedForever => (
        Icons.location_disabled_outlined,
        'Permiso de ubicación bloqueado',
        'Ve a Ajustes > Permisos > Ubicación y elige "Permitir solo mientras se usa la app".',
        'Abrir ajustes',
        () async {
          await service.openAppSettings();
          await controller.refresh();
        },
      ),
      _ => (
        Icons.near_me_outlined,
        'Descubre ofertas cerca de ti',
        'GeoPS usa tu ubicación solo mientras tienes la app abierta, para mostrarte negocios a tu alrededor. '
            'No la guardamos ni la compartimos.',
        'Permitir ubicación',
        controller.request,
      ),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('location.action'),
              onPressed: onPressed,
              icon: const Icon(Icons.my_location),
              label: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
