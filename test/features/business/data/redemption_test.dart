import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/features/business/data/models/business_models.dart';
import 'package:geops_mobile/features/business/domain/entities/business_coupons.dart';
import 'package:geops_mobile/features/coupons/domain/entities/coupon.dart';

Redemption _redemption(DiscountType type, double value, double price) => Redemption(
  code: 'K7QM4XPA',
  couponTitle: 'Cupón',
  discountType: type,
  discountValue: value,
  offerTitle: 'Oferta',
  offerPrice: price,
  redeemedAt: DateTime(2030),
);

void main() {
  test('the final price applies the coupon and never goes below zero', () {
    expect(_redemption(DiscountType.percent, 10, 5).finalPrice, 4.5);
    expect(_redemption(DiscountType.percent, 15, 9.99).finalPrice, 8.49);
    expect(_redemption(DiscountType.fixed, 2, 5).finalPrice, 3);
    expect(_redemption(DiscountType.fixed, 8, 5).finalPrice, 0);
  });

  test('stats days are calendar dates, not shifted by the time zone', () {
    final stats = BusinessStatsModel.fromJson({
      'totalOffers': 3,
      'liveOffers': 2,
      'couponsClaimed': 3,
      'couponsRedeemed': 2,
      'redemptionRate': 67,
      'daily': [
        {'date': '2030-01-10', 'claimed': 3, 'redeemed': 2},
      ],
      'topOffers': [
        {'offerId': 'o-1', 'title': 'Pan', 'claimed': 2, 'redeemed': 2},
      ],
    }).toEntity();

    expect(stats.daily.single.date, DateTime(2030, 1, 10));
    expect(stats.topOffers.single.redeemed, 2);
  });

  test('a coupon input is sent with the API enum names', () {
    const input = CouponInput(title: ' S/ 2 menos ', discountType: DiscountType.fixed, discountValue: 2);

    expect(input.toJson(), {
      'title': 'S/ 2 menos',
      'discountType': 'FIXED',
      'discountValue': 2.0,
      'stock': null,
      'perUserLimit': 1,
    });
  });
}
