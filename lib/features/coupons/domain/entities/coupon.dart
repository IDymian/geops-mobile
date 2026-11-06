import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon.freezed.dart';

enum DiscountType { percent, fixed }

enum UserCouponStatus { claimed, redeemed, expired }

/// A coupon of a live offer that the consumer can claim now.
@freezed
abstract class AvailableCoupon with _$AvailableCoupon {
  const factory AvailableCoupon({
    required String id,
    required String title,
    required DiscountType discountType,
    required double discountValue,

    /// `null` when unlimited.
    int? remaining,
    required int perUserLimit,
    required DateTime validUntil,
  }) = _AvailableCoupon;
}

/// A personal code the consumer claimed. Shown as a QR and as text at the counter.
@freezed
abstract class UserCoupon with _$UserCoupon {
  const factory UserCoupon({
    required String id,
    required String code,
    required UserCouponStatus status,
    required String title,
    required DiscountType discountType,
    required double discountValue,
    required String offerId,
    required String offerTitle,
    required String businessName,
    required String businessAddress,
    required DateTime claimedAt,
    required DateTime validUntil,
    DateTime? redeemedAt,
  }) = _UserCoupon;
}
