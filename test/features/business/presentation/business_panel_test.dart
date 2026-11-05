import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/app/app.dart';
import 'package:geops_mobile/core/location/location_service.dart';
import 'package:geops_mobile/features/auth/data/auth_providers.dart';
import 'package:geops_mobile/features/business/data/business_repository_impl.dart';
import 'package:geops_mobile/features/business/domain/entities/business.dart';
import 'package:geops_mobile/features/business/presentation/providers/business_providers.dart';
import 'package:geops_mobile/features/offers/data/offers_repository_impl.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_business.dart';
import '../../../helpers/fake_offers.dart';

const _business = Business(
  id: 'b-1',
  name: 'Panadería San Martín',
  address: 'Jr. de la Unión 456',
  latitude: -12.0464,
  longitude: -77.0428,
);

void main() {
  late FakeBusinessRepository repository;
  late FakeLocationService location;

  Future<void> pumpPanel(WidgetTester tester, FakeBusinessRepository fake) async {
    repository = fake;
    location = FakeLocationService(initial: LocationAccess.denied);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository(restoredUser: testProvider)),
          businessRepositoryProvider.overrideWithValue(repository),
          offersRepositoryProvider.overrideWithValue(FakeOffersRepository()),
          locationServiceProvider.overrideWithValue(location),
          clockProvider.overrideWithValue(() => panelNow),
        ],
        child: const GeopsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a new provider registers the business at their current location', (tester) async {
    await pumpPanel(tester, FakeBusinessRepository());

    expect(find.text('Registra tu negocio'), findsOneWidget);
    expect(find.byKey(const Key('business.newOffer')), findsNothing);

    await tester.tap(find.byKey(const Key('business.register')));
    await tester.pumpAndSettle();

    // Saving without a location is refused.
    await tester.enterText(find.byKey(const Key('business.name')), 'Panadería San Martín');
    await tester.enterText(find.byKey(const Key('business.address')), 'Jr. de la Unión 456');
    await tester.tap(find.byKey(const Key('business.save')));
    await tester.pumpAndSettle();
    expect(find.text('Marca la ubicación de tu negocio.'), findsOneWidget);
    expect(repository.savedBusiness, isNull);

    await tester.tap(find.byKey(const Key('business.useCurrentLocation')));
    await tester.pumpAndSettle();
    expect(location.requests, 1);

    await tester.tap(find.byKey(const Key('business.save')));
    await tester.pumpAndSettle();

    expect(repository.savedBusiness!.location, plazaDeArmas);
    expect(find.text('Jr. de la Unión 456'), findsOneWidget);
    expect(find.byKey(const Key('business.newOffer')), findsOneWidget);
  });

  testWidgets('lists the offers with their status; expired ones cannot be toggled', (tester) async {
    await pumpPanel(
      tester,
      FakeBusinessRepository(
        business: _business,
        offers: [
          managedOffer('o-1', 'Pan francés 2x1'),
          managedOffer('o-2', 'Keke de naranja', active: false),
          managedOffer('o-3', 'Panetón', endsAt: DateTime(2030, 1, 5)),
        ],
      ),
    );

    expect(find.text('Activa'), findsOneWidget);
    expect(find.text('Pausada'), findsOneWidget);
    expect(find.text('Vencida'), findsOneWidget);
    expect(find.byKey(const Key('offer.toggle.o-3')), findsNothing);
  });

  testWidgets('the switch pauses an offer without changing anything else', (tester) async {
    await pumpPanel(
      tester,
      FakeBusinessRepository(business: _business, offers: [managedOffer('o-1', 'Pan francés 2x1')]),
    );

    await tester.tap(find.byKey(const Key('offer.toggle.o-1')));
    await tester.pumpAndSettle();

    final sent = repository.updatedOffers['o-1']!;
    expect(sent.active, isFalse);
    expect(sent.title, 'Pan francés 2x1');
    expect(sent.offerPrice, 5);
    expect(find.text('Pausada'), findsOneWidget);
  });

  testWidgets('publishes a new offer that ends in a week by default', (tester) async {
    await pumpPanel(tester, FakeBusinessRepository(business: _business));

    await tester.tap(find.byKey(const Key('business.newOffer')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('offer.title')), 'Ceviche + chicha');
    await tester.tap(find.byKey(const Key('offer.category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comida').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('offer.offerPrice')), '25,50');
    await tester.enterText(find.byKey(const Key('offer.originalPrice')), '30');
    await tester.tap(find.byKey(const Key('offer.save')));
    await tester.pumpAndSettle();

    final sent = repository.createdOffer!;
    expect(sent.categorySlug, 'food');
    expect(sent.offerPrice, 25.5);
    expect(sent.originalPrice, 30);
    expect(sent.endsAt, DateTime(2030, 1, 17, 23, 59));
    expect(find.text('Ceviche + chicha'), findsOneWidget);
  });

  testWidgets('an original price below the offer price is rejected before calling the API', (tester) async {
    await pumpPanel(tester, FakeBusinessRepository(business: _business));

    await tester.tap(find.byKey(const Key('business.newOffer')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('offer.title')), 'Ceviche + chicha');
    await tester.enterText(find.byKey(const Key('offer.offerPrice')), '25');
    await tester.enterText(find.byKey(const Key('offer.originalPrice')), '20');
    await tester.tap(find.byKey(const Key('offer.save')));
    await tester.pumpAndSettle();

    expect(find.text('Debe ser mayor o igual al precio de oferta'), findsOneWidget);
    expect(repository.createdOffer, isNull);
  });

  testWidgets('tapping an offer opens it for editing', (tester) async {
    await pumpPanel(
      tester,
      FakeBusinessRepository(business: _business, offers: [managedOffer('o-1', 'Pan francés 2x1')]),
    );

    await tester.tap(find.text('Pan francés 2x1'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('offer.title')), 'Pan francés 3x2');
    await tester.tap(find.byKey(const Key('offer.save')));
    await tester.pumpAndSettle();

    final sent = repository.updatedOffers['o-1']!;
    expect(sent.title, 'Pan francés 3x2');
    expect(sent.startsAt, DateTime(2030, 1, 1));
    expect(find.text('Pan francés 3x2'), findsOneWidget);
  });
}
