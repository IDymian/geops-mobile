import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/app/app.dart';
import 'package:geops_mobile/core/location/location_service.dart';
import 'package:geops_mobile/features/auth/data/auth_providers.dart';
import 'package:geops_mobile/features/business/data/business_repository_impl.dart';
import 'package:geops_mobile/features/business/domain/entities/business.dart';
import 'package:geops_mobile/features/business/domain/entities/business_coupons.dart';
import 'package:geops_mobile/features/business/presentation/providers/business_providers.dart';
import 'package:geops_mobile/features/coupons/domain/entities/coupon.dart';
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

final _stats = BusinessStats(
  totalOffers: 3,
  liveOffers: 2,
  couponsClaimed: 3,
  couponsRedeemed: 2,
  redemptionRate: 67,
  daily: [
    for (var i = 0; i < 7; i++)
      DailyStat(date: DateTime(2030, 1, 4 + i), claimed: i == 6 ? 3 : 0, redeemed: i == 6 ? 2 : 0),
  ],
  topOffers: const [OfferStat(offerId: 'o-1', title: 'Pan francés 2x1', claimed: 2, redeemed: 2)],
);

void main() {
  late FakeBusinessRepository repository;

  Future<void> pumpPanel(WidgetTester tester, FakeBusinessRepository fake) async {
    repository = fake;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository(restoredUser: testProvider)),
          businessRepositoryProvider.overrideWithValue(repository),
          offersRepositoryProvider.overrideWithValue(FakeOffersRepository()),
          locationServiceProvider.overrideWithValue(FakeLocationService(initial: LocationAccess.denied)),
          clockProvider.overrideWithValue(() => panelNow),
        ],
        child: const GeopsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the cashier redeems a code and sees what to charge', (tester) async {
    await pumpPanel(tester, FakeBusinessRepository(business: _business));

    await tester.tap(find.byKey(const Key('business.redeem')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('redeem.code')), 'k7qm-4xpa');
    await tester.tap(find.byKey(const Key('redeem.submit')));
    await tester.pumpAndSettle();

    expect(repository.redeemedCodes, ['K7QM4XPA']);
    expect(find.text('Cupón canjeado'), findsOneWidget);
    expect(find.text('Cliente: Ana'), findsOneWidget);
    // S/ 5.00 offer minus 10%.
    expect(find.text('Cobra S/ 4.50'), findsOneWidget);

    await tester.tap(find.byKey(const Key('redeem.next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('redeem.code')), findsOneWidget);
  });

  testWidgets('an unknown code explains it does not belong to the business', (tester) async {
    await pumpPanel(tester, FakeBusinessRepository(business: _business));

    await tester.tap(find.byKey(const Key('business.redeem')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('redeem.code')), 'ZZZZ-ZZZZ');
    await tester.tap(find.byKey(const Key('redeem.submit')));
    await tester.pumpAndSettle();

    expect(find.text('Este código no existe o no es de tu negocio.'), findsOneWidget);
  });

  testWidgets('a coupon is created from the offer it belongs to', (tester) async {
    await pumpPanel(
      tester,
      FakeBusinessRepository(business: _business, offers: [managedOffer('o-1', 'Pan francés 2x1')]),
    );

    await tester.tap(find.text('Pan francés 2x1'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.byKey(const Key('offer.newCoupon')),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    await tester.tap(find.byKey(const Key('offer.newCoupon')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('coupon.title')), 'S/ 2 menos en caja');
    await tester.tap(find.text('Monto en soles'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('coupon.value')), '2');
    await tester.enterText(find.byKey(const Key('coupon.stock')), '30');
    await tester.tap(find.byKey(const Key('coupon.save')));
    await tester.pumpAndSettle();

    final (offerId, input) = repository.createdCoupon!;
    expect(offerId, 'o-1');
    expect(input.discountType, DiscountType.fixed);
    expect(input.discountValue, 2);
    expect(input.stock, 30);
    // Back on the offer, the new coupon is listed.
    await tester.dragUntilVisible(find.text('S/ 2 menos en caja'), find.byType(ListView).last, const Offset(0, -200));
    expect(find.textContaining('0 obtenidos'), findsOneWidget);
  });

  testWidgets('a percentage over 100 is rejected before calling the API', (tester) async {
    await pumpPanel(
      tester,
      FakeBusinessRepository(business: _business, offers: [managedOffer('o-1', 'Pan francés 2x1')]),
    );

    await tester.tap(find.text('Pan francés 2x1'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.byKey(const Key('offer.newCoupon')),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    await tester.tap(find.byKey(const Key('offer.newCoupon')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('coupon.title')), 'Gratis');
    await tester.enterText(find.byKey(const Key('coupon.value')), '150');
    await tester.tap(find.byKey(const Key('coupon.save')));
    await tester.pumpAndSettle();

    expect(find.text('Máximo 100%'), findsOneWidget);
    expect(repository.createdCoupon, isNull);
  });

  testWidgets('stats show the headline numbers, the week and the top offers', (tester) async {
    await pumpPanel(tester, FakeBusinessRepository(business: _business, statsResult: _stats));

    await tester.tap(find.byKey(const Key('business.stats')));
    await tester.pumpAndSettle();

    expect(find.text('67%'), findsOneWidget);
    expect(find.text('de 3'), findsOneWidget);
    expect(find.text('Obtenidos'), findsOneWidget);
    expect(find.text('Canjeados'), findsOneWidget);
    expect(find.text('10/01'), findsOneWidget);

    await tester.dragUntilVisible(find.text('Pan francés 2x1'), find.byType(ListView).last, const Offset(0, -200));
    expect(find.text('2 canjeados · 2 obtenidos'), findsOneWidget);
  });
}
