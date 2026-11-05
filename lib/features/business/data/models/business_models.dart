import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../offers/data/models/offer_models.dart';
import '../../domain/entities/business.dart';

part 'business_models.freezed.dart';
part 'business_models.g.dart';

@freezed
abstract class BusinessModel with _$BusinessModel {
  const factory BusinessModel({
    required String id,
    required String name,
    String? description,
    String? phone,
    required String address,
    required double latitude,
    required double longitude,
  }) = _BusinessModel;

  const BusinessModel._();

  factory BusinessModel.fromJson(Map<String, Object?> json) => _$BusinessModelFromJson(json);

  Business toEntity() => Business(
    id: id,
    name: name,
    description: description,
    phone: phone,
    address: address,
    latitude: latitude,
    longitude: longitude,
  );
}

@freezed
abstract class ManagedOfferModel with _$ManagedOfferModel {
  const factory ManagedOfferModel({
    required String id,
    required String title,
    String? description,
    String? imageUrl,
    required CategoryModel category,
    double? originalPrice,
    required double offerPrice,
    int? discountPercent,
    required DateTime startsAt,
    required DateTime endsAt,
    required bool active,
  }) = _ManagedOfferModel;

  const ManagedOfferModel._();

  factory ManagedOfferModel.fromJson(Map<String, Object?> json) => _$ManagedOfferModelFromJson(json);

  ManagedOffer toEntity() => ManagedOffer(
    id: id,
    title: title,
    description: description,
    imageUrl: imageUrl,
    category: category.toEntity(),
    originalPrice: originalPrice,
    offerPrice: offerPrice,
    discountPercent: discountPercent,
    startsAt: startsAt.toLocal(),
    endsAt: endsAt.toLocal(),
    active: active,
  );
}

/// Request bodies. Blank optional texts are sent as null; instants always in UTC.
extension BusinessInputJson on BusinessInput {
  Map<String, Object?> toJson() => {
    'name': name.trim(),
    'description': _blankToNull(description),
    'phone': _blankToNull(phone),
    'address': address.trim(),
    'latitude': location.latitude,
    'longitude': location.longitude,
  };
}

extension OfferInputJson on OfferInput {
  Map<String, Object?> toJson() => {
    'title': title.trim(),
    'description': _blankToNull(description),
    'imageUrl': _blankToNull(imageUrl),
    'categorySlug': categorySlug,
    'originalPrice': originalPrice,
    'offerPrice': offerPrice,
    'startsAt': startsAt?.toUtc().toIso8601String(),
    'endsAt': endsAt.toUtc().toIso8601String(),
    'active': active,
  };
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}
