import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../coupons/domain/entities/coupon.dart';

part 'business_coupons.freezed.dart';

/// A coupon the provider issued, with how it is doing.
@freezed
abstract class ProviderCoupon with _$ProviderCoupon {
  const factory ProviderCoupon({
    required String id,
    required String offerId,
    required String offerTitle,
    required String title,
    required DiscountType discountType,
    required double discountValue,
    int? stock,
    required int claimedCount,
    required int redeemedCount,
    int? remaining,
    required int perUserLimit,
    required DateTime validUntil,
    required bool claimable,
  }) = _ProviderCoupon;
}

@freezed
abstract class CouponInput with _$CouponInput {
  const factory CouponInput({
    required String title,
    required DiscountType discountType,
    required double discountValue,

    /// `null` for unlimited.
    int? stock,
    @Default(1) int perUserLimit,
  }) = _CouponInput;
}

/// What the cashier sees after redeeming a code.
@freezed
abstract class Redemption with _$Redemption {
  const factory Redemption({
    required String code,
    required String couponTitle,
    required DiscountType discountType,
    required double discountValue,
    required String offerTitle,
    required double offerPrice,
    String? customerFirstName,
    required DateTime redeemedAt,
  }) = _Redemption;

  const Redemption._();

  /// What the customer pays: the offer price minus the coupon, never below zero.
  double get finalPrice {
    final discount = switch (discountType) {
      DiscountType.percent => offerPrice * discountValue / 100,
      DiscountType.fixed => discountValue,
    };
    final result = offerPrice - discount;
    return result < 0 ? 0 : double.parse(result.toStringAsFixed(2));
  }
}

@freezed
abstract class DailyStat with _$DailyStat {
  const factory DailyStat({required DateTime date, required int claimed, required int redeemed}) = _DailyStat;
}

@freezed
abstract class OfferStat with _$OfferStat {
  const factory OfferStat({
    required String offerId,
    required String title,
    required int claimed,
    required int redeemed,
  }) = _OfferStat;
}

@freezed
abstract class BusinessStats with _$BusinessStats {
  const factory BusinessStats({
    required int totalOffers,
    required int liveOffers,
    required int couponsClaimed,
    required int couponsRedeemed,

    /// 0 to 100.
    required int redemptionRate,
    required List<DailyStat> daily,
    required List<OfferStat> topOffers,
  }) = _BusinessStats;
}
