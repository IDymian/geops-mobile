import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/core/errors/failure.dart';
import 'package:geops_mobile/core/location/location_service.dart';
import 'package:geops_mobile/features/business/data/business_repository_impl.dart';
import 'package:geops_mobile/features/business/domain/entities/business.dart';

/// Answers every request with [status] and [body], and remembers the last request.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status, this.body);

  final int status;
  final Object body;
  late RequestOptions last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  (BusinessRepositoryImpl, _StubAdapter) build(int status, Object body) {
    final adapter = _StubAdapter(status, body);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))..httpClientAdapter = adapter;
    return (BusinessRepositoryImpl(dio), adapter);
  }

  test('a provider without a business gets null, not an error', () async {
    final (repository, _) = build(404, {'status': 404, 'code': 'BUSINESS_NOT_FOUND', 'detail': 'Not found'});

    expect(await repository.mine(), isNull);
  });

  test('other errors still surface as a Failure', () async {
    final (repository, _) = build(500, {'status': 500, 'code': 'INTERNAL_ERROR', 'detail': 'Boom'});

    await expectLater(repository.mine(), throwsA(isA<ApiFailure>()));
  });

  test('saving sends trimmed texts, null for blank optionals and the coordinates', () async {
    final (repository, adapter) = build(200, {
      'id': 'b-1',
      'name': 'Panadería San Martín',
      'address': 'Jr. de la Unión 456',
      'latitude': -12.0464,
      'longitude': -77.0428,
    });

    final business = await repository.save(
      const BusinessInput(
        name: '  Panadería San Martín ',
        description: '   ',
        address: 'Jr. de la Unión 456',
        location: GeoPoint(-12.0464, -77.0428),
      ),
    );

    expect(adapter.last.method, 'PUT');
    expect(adapter.last.path, '/businesses/me');
    expect(adapter.last.data, {
      'name': 'Panadería San Martín',
      'description': null,
      'phone': null,
      'address': 'Jr. de la Unión 456',
      'latitude': -12.0464,
      'longitude': -77.0428,
    });
    expect(business.location, const GeoPoint(-12.0464, -77.0428));
  });

  test('offers are parsed with their category and local dates', () async {
    final (repository, adapter) = build(200, [
      {
        'id': 'o-1',
        'title': 'Pan francés 2x1',
        'category': {'id': 3, 'slug': 'bakery', 'name': 'Panaderías'},
        'originalPrice': 10.0,
        'offerPrice': 5.0,
        'discountPercent': 50,
        'startsAt': '2030-01-01T05:00:00Z',
        'endsAt': '2030-01-16T01:00:00Z',
        'active': false,
        'live': false,
      },
    ]);

    final offers = await repository.offers();

    expect(adapter.last.path, '/businesses/me/offers');
    expect(offers.single.category.slug, 'bakery');
    expect(offers.single.endsAt.isUtc, isFalse);
    expect(offers.single.statusAt(DateTime.utc(2030, 1, 10)), OfferStatus.paused);
  });

  test('creating an offer sends the end date in UTC', () async {
    final (repository, adapter) = build(201, {
      'id': 'o-1',
      'title': 'Pan francés 2x1',
      'category': {'id': 3, 'slug': 'bakery', 'name': 'Panaderías'},
      'offerPrice': 5.0,
      'startsAt': '2030-01-01T05:00:00Z',
      'endsAt': '2030-01-16T01:00:00Z',
      'active': true,
      'live': true,
    });
    final endsAt = DateTime.utc(2030, 1, 16, 1);

    await repository.createOffer(
      OfferInput(title: 'Pan francés 2x1', categorySlug: 'bakery', offerPrice: 5, endsAt: endsAt.toLocal()),
    );

    final sent = adapter.last.data as Map<String, Object?>;
    expect(adapter.last.method, 'POST');
    expect(sent['endsAt'], '2030-01-16T01:00:00.000Z');
    expect(sent['startsAt'], isNull);
    expect(sent['active'], isTrue);
  });
}
