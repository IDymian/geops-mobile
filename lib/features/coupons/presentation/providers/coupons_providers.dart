import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/coupons_repository_impl.dart';
import '../../domain/entities/coupon.dart';

/// Claimable coupons of one offer.
final availableCouponsProvider = FutureProvider.family<List<AvailableCoupon>, String>(
  (ref, offerId) => ref.watch(couponsRepositoryProvider).available(offerId),
);

/// The consumer's codes, newest first.
final myCouponsProvider = FutureProvider<List<UserCoupon>>((ref) => ref.watch(couponsRepositoryProvider).mine());
