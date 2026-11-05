import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/offer.dart';

part 'offer_models.freezed.dart';
part 'offer_models.g.dart';

@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({required String slug, required String name}) = _CategoryModel;

  const CategoryModel._();

  factory CategoryModel.fromJson(Map<String, Object?> json) => _$CategoryModelFromJson(json);

  Category toEntity() => Category(slug: slug, name: name);
}

@freezed
abstract class BusinessSummaryModel with _$BusinessSummaryModel {
  const factory BusinessSummaryModel({
    required String id,
    required String name,
    required String address,
    String? phone,
    required double latitude,
    required double longitude,
  }) = _BusinessSummaryModel;

  const BusinessSummaryModel._();

  factory BusinessSummaryModel.fromJson(Map<String, Object?> json) => _$BusinessSummaryModelFromJson(json);

  BusinessSummary toEntity() =>
      BusinessSummary(id: id, name: name, address: address, phone: phone, latitude: latitude, longitude: longitude);
}

@freezed
abstract class NearbyOfferModel with _$NearbyOfferModel {
  const factory NearbyOfferModel({
    required String id,
    required String title,
    String? imageUrl,
    required String categorySlug,
    double? originalPrice,
    required double offerPrice,
    int? discountPercent,
    required DateTime endsAt,
    required BusinessSummaryModel business,
    required int distanceMeters,
  }) = _NearbyOfferModel;

  const NearbyOfferModel._();

  factory NearbyOfferModel.fromJson(Map<String, Object?> json) => _$NearbyOfferModelFromJson(json);

  NearbyOffer toEntity() => NearbyOffer(
    id: id,
    title: title,
    imageUrl: imageUrl,
    categorySlug: categorySlug,
    originalPrice: originalPrice,
    offerPrice: offerPrice,
    discountPercent: discountPercent,
    endsAt: endsAt.toLocal(),
    business: business.toEntity(),
    distanceMeters: distanceMeters,
  );
}

@freezed
abstract class OfferDetailModel with _$OfferDetailModel {
  const factory OfferDetailModel({
    required String id,
    required String title,
    String? description,
    String? imageUrl,
    required CategoryModel category,
    double? originalPrice,
    required double offerPrice,
    int? discountPercent,
    required DateTime endsAt,
    required BusinessSummaryModel business,
  }) = _OfferDetailModel;

  const OfferDetailModel._();

  factory OfferDetailModel.fromJson(Map<String, Object?> json) => _$OfferDetailModelFromJson(json);

  OfferDetail toEntity() => OfferDetail(
    id: id,
    title: title,
    description: description,
    imageUrl: imageUrl,
    category: category.toEntity(),
    originalPrice: originalPrice,
    offerPrice: offerPrice,
    discountPercent: discountPercent,
    endsAt: endsAt.toLocal(),
    business: business.toEntity(),
  );
}
