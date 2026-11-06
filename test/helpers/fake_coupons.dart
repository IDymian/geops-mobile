import 'package:geops_mobile/core/errors/failure.dart';
import 'package:geops_mobile/features/coupons/domain/entities/coupon.dart';
import 'package:geops_mobile/features/coupons/domain/repositories/coupons_repository.dart';

final testAvailableCoupon = AvailableCoupon(
  id: 'c-1',
  title: '10% extra en pan',
  discountType: DiscountType.percent,
  discountValue: 10,
  remaining: 12,
  perUserLimit: 1,
  validUntil: DateTime(2030, 1, 15, 20),
);

UserCoupon userCoupon({
  String id = 'uc-1',
  String code = 'K7QM4XPA',
  UserCouponStatus status = UserCouponStatus.claimed,
}) => UserCoupon(
  id: id,
  code: code,
  status: status,
  title: '10% extra en pan',
  discountType: DiscountType.percent,
  discountValue: 10,
  offerId: 'o-1',
  offerTitle: 'Pan francés 2x1',
  businessName: 'Panadería San Martín',
  businessAddress: 'Jr. de la Unión 456',
  claimedAt: DateTime(2030, 1, 10, 9),
  validUntil: DateTime(2030, 1, 15, 20),
  redeemedAt: status == UserCouponStatus.redeemed ? DateTime(2030, 1, 11, 10) : null,
);

/// In-memory [CouponsRepository]: claiming adds the code to "mine".
class FakeCouponsRepository implements CouponsRepository {
  FakeCouponsRepository({List<AvailableCoupon>? available, List<UserCoupon>? mine, this.claimFailure})
    : _available = available ?? [testAvailableCoupon],
      _mine = [...?mine];

  final List<AvailableCoupon> _available;
  final List<UserCoupon> _mine;
  Failure? claimFailure;
  final List<String> claims = [];

  @override
  Future<List<AvailableCoupon>> available(String offerId) async => List.of(_available);

  @override
  Future<UserCoupon> claim(String couponId) async {
    claims.add(couponId);
    if (claimFailure != null) throw claimFailure!;
    final claimed = userCoupon(id: 'uc-${claims.length}');
    _mine.insert(0, claimed);
    return claimed;
  }

  @override
  Future<List<UserCoupon>> mine() async => List.of(_mine);
}
