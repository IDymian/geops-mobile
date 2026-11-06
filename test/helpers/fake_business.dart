import 'package:geops_mobile/core/errors/failure.dart';
import 'package:geops_mobile/features/business/domain/entities/business.dart';
import 'package:geops_mobile/features/business/domain/entities/business_coupons.dart';
import 'package:geops_mobile/features/business/domain/repositories/business_repository.dart';
import 'package:geops_mobile/features/coupons/domain/entities/coupon.dart';
import 'package:geops_mobile/features/offers/domain/entities/offer.dart';

/// Fixed "now" for the business panel tests.
final panelNow = DateTime(2030, 1, 10, 12);

const _bakery = Category(slug: 'bakery', name: 'Panaderías');

ManagedOffer managedOffer(String id, String title, {bool active = true, DateTime? endsAt}) => ManagedOffer(
  id: id,
  title: title,
  category: _bakery,
  originalPrice: 10,
  offerPrice: 5,
  discountPercent: 50,
  startsAt: DateTime(2030, 1, 1),
  endsAt: endsAt ?? DateTime(2030, 1, 20, 20),
  active: active,
);

/// In-memory [BusinessRepository] that records what the UI sends.
class FakeBusinessRepository implements BusinessRepository {
  FakeBusinessRepository({
    this.business,
    List<ManagedOffer> offers = const [],
    List<ProviderCoupon> coupons = const [],
    this.statsResult,
  }) : _offers = [...offers],
       _coupons = [...coupons];

  Business? business;
  final List<ManagedOffer> _offers;
  BusinessInput? savedBusiness;
  OfferInput? createdOffer;
  final Map<String, OfferInput> updatedOffers = {};
  final List<ProviderCoupon> _coupons;
  (String, CouponInput)? createdCoupon;
  final List<String> redeemedCodes = [];
  BusinessStats? statsResult;

  /// Codes the fake accepts once; any other code is unknown.
  final Set<String> validCodes = {'K7QM4XPA'};

  @override
  Future<Business?> mine() async => business;

  @override
  Future<Business> save(BusinessInput input) async {
    savedBusiness = input;
    return business = Business(
      id: 'b-1',
      name: input.name.trim(),
      address: input.address.trim(),
      latitude: input.location.latitude,
      longitude: input.location.longitude,
    );
  }

  @override
  Future<List<ManagedOffer>> offers() async => List.of(_offers);

  @override
  Future<ManagedOffer> createOffer(OfferInput input) async {
    createdOffer = input;
    final offer = _fromInput('o-new', input);
    _offers.insert(0, offer);
    return offer;
  }

  @override
  Future<ManagedOffer> updateOffer(String offerId, OfferInput input) async {
    updatedOffers[offerId] = input;
    final offer = _fromInput(offerId, input);
    _offers[_offers.indexWhere((o) => o.id == offerId)] = offer;
    return offer;
  }

  ManagedOffer _fromInput(String id, OfferInput input) => ManagedOffer(
    id: id,
    title: input.title.trim(),
    category: _bakery,
    originalPrice: input.originalPrice,
    offerPrice: input.offerPrice,
    startsAt: input.startsAt ?? panelNow,
    endsAt: input.endsAt,
    active: input.active,
  );

  @override
  Future<List<ProviderCoupon>> coupons() async => List.of(_coupons);

  @override
  Future<ProviderCoupon> createCoupon(String offerId, CouponInput input) async {
    createdCoupon = (offerId, input);
    final coupon = ProviderCoupon(
      id: 'c-${_coupons.length + 1}',
      offerId: offerId,
      offerTitle: 'Oferta',
      title: input.title.trim(),
      discountType: input.discountType,
      discountValue: input.discountValue,
      stock: input.stock,
      claimedCount: 0,
      redeemedCount: 0,
      remaining: input.stock,
      perUserLimit: input.perUserLimit,
      validUntil: DateTime(2030, 1, 20, 20),
      claimable: true,
    );
    _coupons.insert(0, coupon);
    return coupon;
  }

  @override
  Future<Redemption> redeem(String code) async {
    final normalized = code.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
    redeemedCodes.add(normalized);
    if (!validCodes.remove(normalized)) {
      throw const ApiFailure(statusCode: 404, code: 'COUPON_CODE_NOT_FOUND', message: 'Not found');
    }
    return Redemption(
      code: normalized,
      couponTitle: '10% extra',
      discountType: DiscountType.percent,
      discountValue: 10,
      offerTitle: 'Pan francés 2x1',
      offerPrice: 5,
      customerFirstName: 'Ana',
      redeemedAt: panelNow,
    );
  }

  @override
  Future<BusinessStats> stats() async => statsResult!;
}
