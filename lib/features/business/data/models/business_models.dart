import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../coupons/data/models/coupon_models.dart';
import '../../../offers/data/models/offer_models.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/business_coupons.dart';

part 'business_models.freezed.dart';
part 'business_models.g.dart';

@freezed
abstract class BusinessModel with _$BusinessModel {
  const factory BusinessModel({
    required String id,
    required String name,
    String? description,
    String? phone,
    required String address,
    required double latitude,
    required double longitude,
  }) = _BusinessModel;

  const BusinessModel._();

  factory BusinessModel.fromJson(Map<String, Object?> json) => _$BusinessModelFromJson(json);

  Business toEntity() => Business(
    id: id,
    name: name,
    description: description,
    phone: phone,
    address: address,
    latitude: latitude,
    longitude: longitude,
  );
}

@freezed
abstract class ManagedOfferModel with _$ManagedOfferModel {
  const factory ManagedOfferModel({
    required String id,
    required String title,
    String? description,
    String? imageUrl,
    required CategoryModel category,
    double? originalPrice,
    required double offerPrice,
    int? discountPercent,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool active,
  }) = _ManagedOfferModel;

  const ManagedOfferModel._();

  factory ManagedOfferModel.fromJson(Map<String, Object?> json) => _$ManagedOfferModelFromJson(json);

  ManagedOffer toEntity() => ManagedOffer(
    id: id,
    title: title,
    description: description,
    imageUrl: imageUrl,
    category: category.toEntity(),
    originalPrice: originalPrice,
    offerPrice: offerPrice,
    discountPercent: discountPercent,
    startsAt: startsAt.toLocal(),
    endsAt: endsAt.toLocal(),
    active: active,
  );
}

@freezed
abstract class ProviderCouponModel with _$ProviderCouponModel {
  const factory ProviderCouponModel({
    required String id,
    required String offerId,
    required String offerTitle,
    required String title,
    required DiscountTypeModel discountType,
    required double discountValue,
    int? stock,
    required int claimedCount,
    required int redeemedCount,
    int? remaining,
    required int perUserLimit,
    required DateTime validUntil,
    required bool claimable,
  }) = _ProviderCouponModel;

  const ProviderCouponModel._();

  factory ProviderCouponModel.fromJson(Map<String, Object?> json) => _$ProviderCouponModelFromJson(json);

  ProviderCoupon toEntity() => ProviderCoupon(
    id: id,
    offerId: offerId,
    offerTitle: offerTitle,
    title: title,
    discountType: discountType.toEntity(),
    discountValue: discountValue,
    stock: stock,
    claimedCount: claimedCount,
    redeemedCount: redeemedCount,
    remaining: remaining,
    perUserLimit: perUserLimit,
    validUntil: validUntil.toLocal(),
    claimable: claimable,
  );
}

@freezed
abstract class RedemptionModel with _$RedemptionModel {
  const factory RedemptionModel({
    required String code,
    required String couponTitle,
    required DiscountTypeModel discountType,
    required double discountValue,
    required String offerTitle,
    required double offerPrice,
    String? customerFirstName,
    required DateTime redeemedAt,
  }) = _RedemptionModel;

  const RedemptionModel._();

  factory RedemptionModel.fromJson(Map<String, Object?> json) => _$RedemptionModelFromJson(json);

  Redemption toEntity() => Redemption(
    code: code,
    couponTitle: couponTitle,
    discountType: discountType.toEntity(),
    discountValue: discountValue,
    offerTitle: offerTitle,
    offerPrice: offerPrice,
    customerFirstName: customerFirstName,
    redeemedAt: redeemedAt.toLocal(),
  );
}

@freezed
abstract class DailyStatModel with _$DailyStatModel {
  /// [date] is a calendar day in Lima time (`2030-01-10`), not an instant.
  const factory DailyStatModel({required String date, required int claimed, required int redeemed}) = _DailyStatModel;

  const DailyStatModel._();

  factory DailyStatModel.fromJson(Map<String, Object?> json) => _$DailyStatModelFromJson(json);

  DailyStat toEntity() => DailyStat(date: DateTime.parse(date), claimed: claimed, redeemed: redeemed);
}

@freezed
abstract class OfferStatModel with _$OfferStatModel {
  const factory OfferStatModel({
    required String offerId,
    required String title,
    required int claimed,
    required int redeemed,
  }) = _OfferStatModel;

  const OfferStatModel._();

  factory OfferStatModel.fromJson(Map<String, Object?> json) => _$OfferStatModelFromJson(json);

  OfferStat toEntity() => OfferStat(offerId: offerId, title: title, claimed: claimed, redeemed: redeemed);
}

@freezed
abstract class BusinessStatsModel with _$BusinessStatsModel {
  const factory BusinessStatsModel({
    required int totalOffers,
    required int liveOffers,
    required int couponsClaimed,
    required int couponsRedeemed,
    required int redemptionRate,
    required List<DailyStatModel> daily,
    required List<OfferStatModel> topOffers,
  }) = _BusinessStatsModel;

  const BusinessStatsModel._();

  factory BusinessStatsModel.fromJson(Map<String, Object?> json) => _$BusinessStatsModelFromJson(json);

  BusinessStats toEntity() => BusinessStats(
    totalOffers: totalOffers,
    liveOffers: liveOffers,
    couponsClaimed: couponsClaimed,
    couponsRedeemed: couponsRedeemed,
    redemptionRate: redemptionRate,
    daily: [for (final day in daily) day.toEntity()],
    topOffers: [for (final offer in topOffers) offer.toEntity()],
  );
}

/// Request bodies. Blank optional texts are sent as null; instants always in UTC.
extension BusinessInputJson on BusinessInput {
  Map<String, Object?> toJson() => {
    'name': name.trim(),
    'description': _blankToNull(description),
    'phone': _blankToNull(phone),
    'address': address.trim(),
    'latitude': location.latitude,
    'longitude': location.longitude,
  };
}

extension OfferInputJson on OfferInput {
  Map<String, Object?> toJson() => {
    'title': title.trim(),
    'description': _blankToNull(description),
    'imageUrl': _blankToNull(imageUrl),
    'categorySlug': categorySlug,
    'originalPrice': originalPrice,
    'offerPrice': offerPrice,
    'startsAt': startsAt?.toUtc().toIso8601String(),
    'endsAt': endsAt.toUtc().toIso8601String(),
    'active': active,
  };
}

extension CouponInputJson on CouponInput {
  Map<String, Object?> toJson() => {
    'title': title.trim(),
    'discountType': discountType.name.toUpperCase(),
    'discountValue': discountValue,
    'stock': stock,
    'perUserLimit': perUserLimit,
  };
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}
