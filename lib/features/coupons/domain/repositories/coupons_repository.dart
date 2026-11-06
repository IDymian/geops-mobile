import '../entities/coupon.dart';

/// Consumer side of coupons. Implementations throw a `Failure` on errors.
abstract interface class CouponsRepository {
  /// Coupons of a live offer that can be claimed now.
  Future<List<AvailableCoupon>> available(String offerId);

  /// Claims a coupon and returns the personal code.
  Future<UserCoupon> claim(String couponId);

  /// The consumer's codes, newest first.
  Future<List<UserCoupon>> mine();
}
