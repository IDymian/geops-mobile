import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/entities/coupon.dart';
import '../domain/repositories/coupons_repository.dart';
import 'models/coupon_models.dart';

class CouponsRepositoryImpl implements CouponsRepository {
  CouponsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<AvailableCoupon>> available(String offerId) => _guard(() async {
    final response = await _dio.get<List<Object?>>('/offers/$offerId/coupons');
    return [for (final json in response.data!) AvailableCouponModel.fromJson(json! as Map<String, Object?>).toEntity()];
  });

  @override
  Future<UserCoupon> claim(String couponId) => _guard(() async {
    final response = await _dio.post<Map<String, Object?>>('/coupons/$couponId/claim');
    return UserCouponModel.fromJson(response.data!).toEntity();
  });

  @override
  Future<List<UserCoupon>> mine() => _guard(() async {
    final response = await _dio.get<List<Object?>>('/users/me/coupons');
    return [for (final json in response.data!) UserCouponModel.fromJson(json! as Map<String, Object?>).toEntity()];
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw mapError(error);
    }
  }
}

final couponsRepositoryProvider = Provider<CouponsRepository>((ref) => CouponsRepositoryImpl(ref.watch(dioProvider)));
