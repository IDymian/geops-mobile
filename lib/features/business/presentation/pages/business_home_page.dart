import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../../domain/entities/business.dart';
import '../business_failure_messages.dart';
import '../providers/business_providers.dart';
import '../widgets/managed_offer_tile.dart';

/// Provider home: their business and its offers.
class BusinessHomePage extends ConsumerWidget {
  const BusinessHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(myBusinessProvider);
    final hasBusiness = business.value != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi negocio'),
        actions: [
          if (hasBusiness)
            IconButton(
              key: const Key('business.stats'),
              tooltip: 'Estadísticas',
              icon: const Icon(Icons.insights_outlined),
              onPressed: () => context.push(AppRoutes.stats),
            ),
          const LogoutButton(),
        ],
      ),
      floatingActionButton: hasBusiness
          ? FloatingActionButton.extended(
              key: const Key('business.newOffer'),
              onPressed: () => context.push(AppRoutes.newOffer),
              icon: const Icon(Icons.add),
              label: const Text('Nueva oferta'),
            )
          : null,
      body: business.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            _RetryView(message: businessFailureMessage(error), onRetry: () => ref.invalidate(myBusinessProvider)),
        data: (business) => business == null ? const _Onboarding() : _Panel(business: business),
      ),
    );
  }
}

class _Onboarding extends StatelessWidget {
  const _Onboarding();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront_outlined, size: 56),
          const SizedBox(height: 16),
          Text('Registra tu negocio', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Agrega su nombre, dirección y ubicación para que los clientes cercanos vean tus ofertas.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('business.register'),
            onPressed: () => context.push(AppRoutes.businessProfile),
            child: const Text('Registrar negocio'),
          ),
        ],
      ),
    ),
  );
}

class _Panel extends ConsumerWidget {
  const _Panel({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(myOffersProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myOffersProvider.future),
      child: ListView(
        // Room for the floating button over the last offer.
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(business.name),
              subtitle: Text(business.address),
              trailing: IconButton(
                key: const Key('business.edit'),
                tooltip: 'Editar negocio',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(AppRoutes.businessProfile),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            key: const Key('business.redeem'),
            onPressed: () => context.push(AppRoutes.redeem),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Canjear cupón'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text('Mis ofertas', style: theme.textTheme.titleMedium),
          ),
          ...offers.when(
            skipLoadingOnReload: true,
            loading: () => const [
              Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (error, _) => [
              _RetryView(message: businessFailureMessage(error), onRetry: () => ref.invalidate(myOffersProvider)),
            ],
            data: (list) => list.isEmpty
                ? const [
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aún no tienes ofertas. Publica la primera con "Nueva oferta".',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]
                : [
                    for (final offer in list)
                      ManagedOfferTile(offer: offer, onTap: () => context.push(AppRoutes.editOffer(offer.id))),
                  ],
          ),
        ],
      ),
    );
  }
}

class _RetryView extends StatelessWidget {
  const _RetryView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}
