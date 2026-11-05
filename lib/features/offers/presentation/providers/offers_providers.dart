import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/location/location_service.dart';
import '../../data/offers_repository_impl.dart';
import '../../domain/entities/offer.dart';

// --- location ---

class LocationState {
  const LocationState(this.access, [this.position]);

  final LocationAccess access;
  final GeoPoint? position;
}

/// Location permission and the user's position. Never asks on its own:
/// the system dialog appears only after the user taps "Permitir ubicación".
class LocationController extends AsyncNotifier<LocationState> {
  LocationService get _service => ref.read(locationServiceProvider);

  @override
  Future<LocationState> build() async => _resolve(await _service.currentAccess());

  Future<void> request() async {
    state = const AsyncLoading<LocationState>();
    state = await AsyncValue.guard(() async => _resolve(await _service.requestAccess()));
  }

  Future<void> refresh() async {
    state = const AsyncLoading<LocationState>();
    state = await AsyncValue.guard(build);
  }

  Future<LocationState> _resolve(LocationAccess access) async => access == LocationAccess.granted
      ? LocationState(access, await _service.currentPosition())
      : LocationState(access);
}

final locationProvider = AsyncNotifierProvider<LocationController, LocationState>(LocationController.new);

// --- filters ---

class SearchFilters {
  const SearchFilters({this.radiusMeters = 2000, this.categorySlug});

  static const radiusOptions = [500, 1000, 2000, 5000, 10000];

  final int radiusMeters;
  final String? categorySlug;
}

class SearchFiltersController extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void setRadius(int meters) => state = SearchFilters(radiusMeters: meters, categorySlug: state.categorySlug);

  /// Tapping the selected category again clears the filter.
  void toggleCategory(String slug) =>
      state = SearchFilters(radiusMeters: state.radiusMeters, categorySlug: state.categorySlug == slug ? null : slug);
}

final searchFiltersProvider = NotifierProvider<SearchFiltersController, SearchFilters>(SearchFiltersController.new);

// --- view mode ---

enum OffersView { map, list }

class OffersViewController extends Notifier<OffersView> {
  @override
  OffersView build() => OffersView.map;

  void toggle() => state = state == OffersView.map ? OffersView.list : OffersView.map;
}

final offersViewProvider = NotifierProvider<OffersViewController, OffersView>(OffersViewController.new);

// --- data ---

final categoriesProvider = FutureProvider<List<Category>>((ref) => ref.watch(offersRepositoryProvider).categories());

/// Re-runs when the position or any filter changes. Empty until the location is known.
final nearbyOffersProvider = FutureProvider<List<NearbyOffer>>((ref) async {
  final position = (await ref.watch(locationProvider.future)).position;
  if (position == null) return const [];
  final filters = ref.watch(searchFiltersProvider);
  return ref
      .watch(offersRepositoryProvider)
      .nearby(point: position, radiusMeters: filters.radiusMeters, categorySlug: filters.categorySlug);
});

final offerDetailProvider = FutureProvider.family<OfferDetail, String>(
  (ref, offerId) => ref.watch(offersRepositoryProvider).detail(offerId),
);
