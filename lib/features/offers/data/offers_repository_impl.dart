import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/location/location_service.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/entities/offer.dart';
import '../domain/repositories/offers_repository.dart';
import 'models/offer_models.dart';

class OffersRepositoryImpl implements OffersRepository {
  OffersRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Category>> categories() => _guard(() async {
    final response = await _dio.get<List<Object?>>('/categories');
    return [for (final json in response.data!) CategoryModel.fromJson(json! as Map<String, Object?>).toEntity()];
  });

  @override
  Future<List<NearbyOffer>> nearby({required GeoPoint point, required int radiusMeters, String? categorySlug}) =>
      _guard(() async {
        final response = await _dio.get<List<Object?>>(
          '/offers/nearby',
          queryParameters: {
            'lat': point.latitude,
            'lng': point.longitude,
            'radius': radiusMeters,
            'category': ?categorySlug,
          },
        );
        return [for (final json in response.data!) NearbyOfferModel.fromJson(json! as Map<String, Object?>).toEntity()];
      });

  @override
  Future<OfferDetail> detail(String offerId) => _guard(() async {
    final response = await _dio.get<Map<String, Object?>>('/offers/$offerId');
    return OfferDetailModel.fromJson(response.data!).toEntity();
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw mapError(error);
    }
  }
}

final offersRepositoryProvider = Provider<OffersRepository>((ref) => OffersRepositoryImpl(ref.watch(dioProvider)));
