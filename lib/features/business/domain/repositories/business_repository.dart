import '../entities/business.dart';

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
}
