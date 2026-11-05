import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer.freezed.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({required String slug, required String name}) = _Category;
}

@freezed
abstract class BusinessSummary with _$BusinessSummary {
  const factory BusinessSummary({
    required String id,
    required String name,
    required String address,
    String? phone,
    required double latitude,
    required double longitude,
  }) = _BusinessSummary;
}

/// An offer found by a radius search.
@freezed
abstract class NearbyOffer with _$NearbyOffer {
  const factory NearbyOffer({
    required String id,
    required String title,
    String? imageUrl,
    required String categorySlug,
    double? originalPrice,
    required double offerPrice,
    int? discountPercent,
    required DateTime endsAt,
    required BusinessSummary business,
    required int distanceMeters,
  }) = _NearbyOffer;
}

@freezed
abstract class OfferDetail with _$OfferDetail {
  const factory OfferDetail({
    required String id,
    required String title,
    String? description,
    String? imageUrl,
    required Category category,
    double? originalPrice,
    required double offerPrice,
    int? discountPercent,
    required DateTime endsAt,
    required BusinessSummary business,
  }) = _OfferDetail;
}
