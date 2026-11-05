import 'package:geops_mobile/core/location/location_service.dart';
import 'package:geops_mobile/features/offers/domain/entities/offer.dart';
import 'package:geops_mobile/features/offers/domain/repositories/offers_repository.dart';
import 'package:geops_mobile/features/offers/presentation/providers/offers_providers.dart';

const plazaDeArmas = GeoPoint(-12.0464, -77.0428);

const _bakery = BusinessSummary(
  id: 'b-1',
  name: 'Panadería San Martín',
  address: 'Jr. de la Unión 456',
  phone: '+51 987 654 321',
  latitude: -12.0464,
  longitude: -77.0428,
);
const _restaurant = BusinessSummary(
  id: 'b-2',
  name: 'Cevichería El Puerto',
  address: 'Av. Abancay 210',
  latitude: -12.0329,
  longitude: -77.0428,
);

final testOffers = [
  NearbyOffer(
    id: 'o-1',
    title: 'Pan francés 2x1',
    categorySlug: 'bakery',
    originalPrice: 10,
    offerPrice: 5,
    discountPercent: 50,
    endsAt: DateTime(2030, 1, 15, 20),
    business: _bakery,
    distanceMeters: 120,
  ),
  NearbyOffer(
    id: 'o-2',
    title: 'Ceviche + chicha',
    categorySlug: 'food',
    offerPrice: 25,
    endsAt: DateTime(2030, 1, 20, 22),
    business: _restaurant,
    distanceMeters: 1500,
  ),
];

/// Location that starts with [initial] access and becomes [afterRequest] when asked.
class FakeLocationService implements LocationService {
  FakeLocationService({required this.initial, this.afterRequest = LocationAccess.granted});

  LocationAccess initial;
  final LocationAccess afterRequest;
  int requests = 0;

  @override
  Future<LocationAccess> currentAccess() async => initial;

  @override
  Future<LocationAccess> requestAccess() async {
    requests++;
    return initial = afterRequest;
  }

  @override
  Future<GeoPoint> currentPosition() async => plazaDeArmas;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}

class FakeOffersRepository implements OffersRepository {
  final List<String?> categoryQueries = [];

  @override
  Future<List<Category>> categories() async => const [
    Category(slug: 'food', name: 'Comida'),
    Category(slug: 'bakery', name: 'Panaderías'),
  ];

  @override
  Future<List<NearbyOffer>> nearby({required GeoPoint point, required int radiusMeters, String? categorySlug}) async {
    categoryQueries.add(categorySlug);
    return testOffers.where((o) => categorySlug == null || o.categorySlug == categorySlug).toList();
  }

  @override
  Future<OfferDetail> detail(String offerId) async {
    final offer = testOffers.firstWhere((o) => o.id == offerId);
    return OfferDetail(
      id: offer.id,
      title: offer.title,
      description: 'Válido de lunes a viernes',
      category: const Category(slug: 'bakery', name: 'Panaderías'),
      originalPrice: offer.originalPrice,
      offerPrice: offer.offerPrice,
      discountPercent: offer.discountPercent,
      endsAt: offer.endsAt,
      business: offer.business,
    );
  }
}

/// Widget tests cannot render Google Maps (a platform view), so they start on the list.
class ListFirstView extends OffersViewController {
  @override
  OffersView build() => OffersView.list;
}
