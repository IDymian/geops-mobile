import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/app/app.dart';
import 'package:geops_mobile/core/location/location_service.dart';
import 'package:geops_mobile/features/auth/data/auth_providers.dart';
import 'package:geops_mobile/features/coupons/data/coupons_repository_impl.dart';
import 'package:geops_mobile/features/offers/data/offers_repository_impl.dart';
import 'package:geops_mobile/features/offers/presentation/providers/offers_providers.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_coupons.dart';
import '../../../helpers/fake_offers.dart';

void main() {
  late FakeOffersRepository offers;

  Future<void> pumpHome(WidgetTester tester, FakeLocationService location) async {
    offers = FakeOffersRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository(restoredUser: testConsumer)),
          locationServiceProvider.overrideWithValue(location),
          offersRepositoryProvider.overrideWithValue(offers),
          offersViewProvider.overrideWith(ListFirstView.new),
          couponsRepositoryProvider.overrideWithValue(FakeCouponsRepository(available: [])),
        ],
        child: const GeopsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('explains why location is needed and asks only after the tap', (tester) async {
    final location = FakeLocationService(initial: LocationAccess.denied);
    await pumpHome(tester, location);

    expect(find.text('Descubre ofertas cerca de ti'), findsOneWidget);
    expect(location.requests, 0);

    await tester.tap(find.byKey(const Key('location.action')));
    await tester.pumpAndSettle();

    expect(location.requests, 1);
    expect(find.text('Pan francés 2x1'), findsOneWidget);
  });

  testWidgets('a blocked permission points to the settings', (tester) async {
    await pumpHome(tester, FakeLocationService(initial: LocationAccess.deniedForever));

    expect(find.text('Abrir ajustes'), findsOneWidget);
  });

  testWidgets('lists nearby offers closest first with distance, price and discount', (tester) async {
    await pumpHome(tester, FakeLocationService(initial: LocationAccess.granted));

    expect(find.text('Panadería San Martín · 120 m'), findsOneWidget);
    expect(find.text('Cevichería El Puerto · 1,5 km'), findsOneWidget);
    expect(find.text('S/ 5.00'), findsOneWidget);
    expect(find.text('-50%'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Pan francés 2x1')).dy,
      lessThan(tester.getTopLeft(find.text('Ceviche + chicha')).dy),
    );
  });

  testWidgets('filtering by category searches again', (tester) async {
    await pumpHome(tester, FakeLocationService(initial: LocationAccess.granted));

    await tester.tap(find.widgetWithText(FilterChip, 'Panaderías'));
    await tester.pumpAndSettle();

    expect(offers.categoryQueries.last, 'bakery');
    expect(find.text('Ceviche + chicha'), findsNothing);
  });

  testWidgets('tapping an offer opens its detail with the business', (tester) async {
    await pumpHome(tester, FakeLocationService(initial: LocationAccess.granted));

    await tester.tap(find.text('Pan francés 2x1'));
    await tester.pumpAndSettle();

    expect(find.text('Válido de lunes a viernes'), findsOneWidget);
    expect(find.text('Jr. de la Unión 456'), findsOneWidget);
  });
}
