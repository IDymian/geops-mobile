import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/location/location_service.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../../domain/entities/offer.dart';
import '../offers_failure_messages.dart';
import '../providers/offers_providers.dart';
import '../widgets/filters_bar.dart';
import '../widgets/location_request_view.dart';
import '../widgets/offer_card.dart';
import '../widgets/offers_map.dart';

/// Consumer home: offers around the user, on a map or as a list.
class OffersHomePage extends ConsumerWidget {
  const OffersHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final view = ref.watch(offersViewProvider);
    final hasPosition = location.value?.position != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas cerca de ti'),
        actions: [
          if (hasPosition)
            IconButton(
              key: const Key('offers.toggleView'),
              tooltip: view == OffersView.map ? 'Ver lista' : 'Ver mapa',
              icon: Icon(view == OffersView.map ? Icons.view_list_outlined : Icons.map_outlined),
              onPressed: ref.read(offersViewProvider.notifier).toggle,
            ),
          const LogoutButton(),
        ],
      ),
      body: location.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: 'No pudimos obtener tu ubicación.',
          onRetry: ref.read(locationProvider.notifier).refresh,
        ),
        data: (state) {
          final position = state.position;
          if (state.access != LocationAccess.granted || position == null) {
            return LocationRequestView(access: state.access);
          }
          return Column(
            children: [
              const FiltersBar(),
              Expanded(
                child: _Results(position: position, view: view),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.position, required this.view});

  final GeoPoint position;
  final OffersView view;

  void _open(BuildContext context, NearbyOffer offer) => context.push(AppRoutes.offerDetail(offer.id));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(nearbyOffersProvider);
    final radius = ref.watch(searchFiltersProvider).radiusMeters;

    if (offers.hasError && !offers.hasValue) {
      return _ErrorView(
        message: offersFailureMessage(offers.error!),
        onRetry: () => ref.invalidate(nearbyOffersProvider),
      );
    }
    final list = offers.value ?? const <NearbyOffer>[];

    final content = view == OffersView.map
        ? OffersMap(center: position, radiusMeters: radius, offers: list, onOfferTap: (offer) => _open(context, offer))
        : list.isEmpty && !offers.isLoading
        ? const _EmptyView()
        : RefreshIndicator(
            onRefresh: () => ref.refresh(nearbyOffersProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => OfferCard(offer: list[i], onTap: () => _open(context, list[i])),
            ),
          );

    return Stack(
      children: [
        Positioned.fill(child: content),
        if (offers.isLoading) const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator()),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'No hay ofertas activas en esta zona. Prueba con un radio más grande u otra categoría.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

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
