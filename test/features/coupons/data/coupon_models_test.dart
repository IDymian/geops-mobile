import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/features/coupons/data/models/coupon_models.dart';
import 'package:geops_mobile/features/coupons/domain/entities/coupon.dart';

void main() {
  test('a claimed code is parsed from the API JSON, with local dates', () {
    final coupon = UserCouponModel.fromJson({
      'id': 'uc-1',
      'code': 'K7QM4XPA',
      'status': 'REDEEMED',
      'title': '10% extra',
      'discountType': 'PERCENT',
      'discountValue': 10,
      'offerId': 'o-1',
      'offerTitle': 'Pan francés 2x1',
      'businessName': 'Panadería San Martín',
      'businessAddress': 'Jr. de la Unión 456',
      'claimedAt': '2030-01-10T14:00:00Z',
      'validUntil': '2030-01-16T01:00:00Z',
      'redeemedAt': '2030-01-11T15:00:00Z',
    }).toEntity();

    expect(coupon.status, UserCouponStatus.redeemed);
    expect(coupon.discountType, DiscountType.percent);
    expect(coupon.discountValue, 10.0);
    expect(coupon.redeemedAt!.isUtc, isFalse);
  });

  test('an unlimited coupon has no remaining count', () {
    final coupon = AvailableCouponModel.fromJson({
      'id': 'c-1',
      'title': 'S/ 2 menos',
      'discountType': 'FIXED',
      'discountValue': 2.5,
      'remaining': null,
      'perUserLimit': 1,
      'validUntil': '2030-01-16T01:00:00Z',
    }).toEntity();

    expect(coupon.discountType, DiscountType.fixed);
    expect(coupon.remaining, isNull);
  });
}
