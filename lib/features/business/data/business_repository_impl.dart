import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/entities/business.dart';
import '../domain/entities/business_coupons.dart';
import '../domain/repositories/business_repository.dart';
import 'models/business_models.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  BusinessRepositoryImpl(this._dio);

  static const _base = '/businesses/me';

  final Dio _dio;

  @override
  Future<Business?> mine() async {
    try {
      return await _guard(() async {
        final response = await _dio.get<Map<String, Object?>>(_base);
        return BusinessModel.fromJson(response.data!).toEntity();
      });
    } on ApiFailure catch (failure) {
      // Not an error for the UI: the provider simply has not registered the business yet.
      if (failure.code == 'BUSINESS_NOT_FOUND') return null;
      rethrow;
    }
  }

  @override
  Future<Business> save(BusinessInput input) => _guard(() async {
    final response = await _dio.put<Map<String, Object?>>(_base, data: input.toJson());
    return BusinessModel.fromJson(response.data!).toEntity();
  });

  @override
  Future<List<ManagedOffer>> offers() => _guard(() async {
    final response = await _dio.get<List<Object?>>('$_base/offers');
    return [for (final json in response.data!) ManagedOfferModel.fromJson(json! as Map<String, Object?>).toEntity()];
  });

  @override
  Future<ManagedOffer> createOffer(OfferInput input) => _guard(() async {
    final response = await _dio.post<Map<String, Object?>>('$_base/offers', data: input.toJson());
    return ManagedOfferModel.fromJson(response.data!).toEntity();
  });

  @override
  Future<ManagedOffer> updateOffer(String offerId, OfferInput input) => _guard(() async {
    final response = await _dio.put<Map<String, Object?>>('$_base/offers/$offerId', data: input.toJson());
    return ManagedOfferModel.fromJson(response.data!).toEntity();
  });

  @override
  Future<List<ProviderCoupon>> coupons() => _guard(() async {
    final response = await _dio.get<List<Object?>>('$_base/coupons');
    return [for (final json in response.data!) ProviderCouponModel.fromJson(json! as Map<String, Object?>).toEntity()];
  });

  @override
  Future<ProviderCoupon> createCoupon(String offerId, CouponInput input) => _guard(() async {
    final response = await _dio.post<Map<String, Object?>>('$_base/offers/$offerId/coupons', data: input.toJson());
    return ProviderCouponModel.fromJson(response.data!).toEntity();
  });

  @override
  Future<Redemption> redeem(String code) => _guard(() async {
    final response = await _dio.post<Map<String, Object?>>('$_base/redemptions', data: {'code': code.trim()});
    return RedemptionModel.fromJson(response.data!).toEntity();
  });

  @override
  Future<BusinessStats> stats() => _guard(() async {
    final response = await _dio.get<Map<String, Object?>>('$_base/stats');
    return BusinessStatsModel.fromJson(response.data!).toEntity();
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw mapError(error);
    }
  }
}

final businessRepositoryProvider = Provider<BusinessRepository>(
  (ref) => BusinessRepositoryImpl(ref.watch(dioProvider)),
);
