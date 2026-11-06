import '../entities/business.dart';
import '../entities/business_coupons.dart';

/// The provider's business panel. Implementations throw a `Failure` on errors.
abstract interface class BusinessRepository {
  /// The provider's business, or `null` if they have not registered it yet.
  Future<Business?> mine();

  /// Creates the business the first time, updates it afterwards.
  Future<Business> save(BusinessInput input);

  /// All the provider's offers, newest first.
  Future<List<ManagedOffer>> offers();

  Future<ManagedOffer> createOffer(OfferInput input);

  /// Edits, pauses (`active: false`) or reactivates an offer.
  Future<ManagedOffer> updateOffer(String offerId, OfferInput input);

  /// All the provider's coupons, newest first.
  Future<List<ProviderCoupon>> coupons();

  Future<ProviderCoupon> createCoupon(String offerId, CouponInput input);

  /// Redeems a customer's code at the counter. Dashes, spaces and case are ignored by the API.
  Future<Redemption> redeem(String code);

  Future<BusinessStats> stats();
}
