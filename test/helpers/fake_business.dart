import 'package:geops_mobile/features/business/domain/entities/business.dart';
import 'package:geops_mobile/features/business/domain/repositories/business_repository.dart';
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
  FakeBusinessRepository({this.business, List<ManagedOffer> offers = const []}) : _offers = [...offers];

  Business? business;
  final List<ManagedOffer> _offers;
  BusinessInput? savedBusiness;
  OfferInput? createdOffer;
  final Map<String, OfferInput> updatedOffers = {};

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
}
