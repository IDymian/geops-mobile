import '../../../../core/location/location_service.dart';
import '../entities/offer.dart';

/// Offer discovery. Implementations throw a `Failure` on errors.
abstract interface class OffersRepository {
  Future<List<Category>> categories();

  /// Live offers within [radiusMeters] of [point], closest first.
  Future<List<NearbyOffer>> nearby({required GeoPoint point, required int radiusMeters, String? categorySlug});

  Future<OfferDetail> detail(String offerId);
}
