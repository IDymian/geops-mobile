import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/location/location_service.dart';
import '../../../offers/domain/entities/offer.dart';

part 'business.freezed.dart';

/// The signed-in provider's business.
@freezed
abstract class Business with _$Business {
  const factory Business({
    required String id,
    required String name,
    String? description,
    String? phone,
    required String address,
    required double latitude,
    required double longitude,
  }) = _Business;

  const Business._();

  GeoPoint get location => GeoPoint(latitude, longitude);
}

/// What the provider fills in to create or update the business.
@freezed
abstract class BusinessInput with _$BusinessInput {
  const factory BusinessInput({
    required String name,
    String? description,
    String? phone,
    required String address,
    required GeoPoint location,
  }) = _BusinessInput;
}

/// Where an offer stands, from the provider's point of view.
enum OfferStatus { live, scheduled, paused, expired }

/// One of the provider's own offers (including paused and expired ones).
@freezed
abstract class ManagedOffer with _$ManagedOffer {
  const factory ManagedOffer({
    required String id,
    required String title,
    String? description,
    String? imageUrl,
    required Category category,
    double? originalPrice,
    required double offerPrice,
    int? discountPercent,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool active,
  }) = _ManagedOffer;

  const ManagedOffer._();

  OfferStatus statusAt(DateTime now) {
    if (!endsAt.isAfter(now)) return OfferStatus.expired;
    if (!active) return OfferStatus.paused;
    if (startsAt.isAfter(now)) return OfferStatus.scheduled;
    return OfferStatus.live;
  }

  /// The same offer as input, e.g. to pause it without touching anything else.
  OfferInput toInput() => OfferInput(
    title: title,
    description: description,
    imageUrl: imageUrl,
    categorySlug: category.slug,
    originalPrice: originalPrice,
    offerPrice: offerPrice,
    startsAt: startsAt,
    endsAt: endsAt,
    active: active,
  );
}

@freezed
abstract class OfferInput with _$OfferInput {
  const factory OfferInput({
    required String title,
    String? description,
    String? imageUrl,
    required String categorySlug,
    double? originalPrice,
    required double offerPrice,
    DateTime? startsAt,
    required DateTime endsAt,
    @Default(true) bool active,
  }) = _OfferInput;
}
