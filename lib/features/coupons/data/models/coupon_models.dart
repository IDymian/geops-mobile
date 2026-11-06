import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/coupon.dart';

part 'coupon_models.freezed.dart';
part 'coupon_models.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum DiscountTypeModel {
  percent,
  fixed;

  DiscountType toEntity() => DiscountType.values.byName(name);
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum UserCouponStatusModel {
  claimed,
  redeemed,
  expired;

  UserCouponStatus toEntity() => UserCouponStatus.values.byName(name);
}

@freezed
abstract class AvailableCouponModel with _$AvailableCouponModel {
  const factory AvailableCouponModel({
    required String id,
    required String title,
    required DiscountTypeModel discountType,
    required double discountValue,
    int? remaining,
    required int perUserLimit,
    required DateTime validUntil,
  }) = _AvailableCouponModel;

  const AvailableCouponModel._();

  factory AvailableCouponModel.fromJson(Map<String, Object?> json) => _$AvailableCouponModelFromJson(json);

  AvailableCoupon toEntity() => AvailableCoupon(
    id: id,
    title: title,
    discountType: discountType.toEntity(),
    discountValue: discountValue,
    remaining: remaining,
    perUserLimit: perUserLimit,
    validUntil: validUntil.toLocal(),
  );
}

@freezed
abstract class UserCouponModel with _$UserCouponModel {
  const factory UserCouponModel({
    required String id,
    required String code,
    required UserCouponStatusModel status,
    required String title,
    required DiscountTypeModel discountType,
    required double discountValue,
    required String offerId,
    required String offerTitle,
    required String businessName,
    required String businessAddress,
    required DateTime claimedAt,
    required DateTime validUntil,
    DateTime? redeemedAt,
  }) = _UserCouponModel;

  const UserCouponModel._();

  factory UserCouponModel.fromJson(Map<String, Object?> json) => _$UserCouponModelFromJson(json);

  UserCoupon toEntity() => UserCoupon(
    id: id,
    code: code,
    status: status.toEntity(),
    title: title,
    discountType: discountType.toEntity(),
    discountValue: discountValue,
    offerId: offerId,
    offerTitle: offerTitle,
    businessName: businessName,
    businessAddress: businessAddress,
    claimedAt: claimedAt.toLocal(),
    validUntil: validUntil.toLocal(),
    redeemedAt: redeemedAt?.toLocal(),
  );
}
