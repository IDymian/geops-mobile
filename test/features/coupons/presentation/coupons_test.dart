import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/app/app.dart';
import 'package:geops_mobile/core/errors/failure.dart';
import 'package:geops_mobile/core/location/location_service.dart';
import 'package:geops_mobile/features/auth/data/auth_providers.dart';
import 'package:geops_mobile/features/coupons/data/coupons_repository_impl.dart';
import 'package:geops_mobile/features/coupons/domain/entities/coupon.dart';
import 'package:geops_mobile/features/offers/data/offers_repository_impl.dart';
import 'package:geops_mobile/features/offers/presentation/providers/offers_providers.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_coupons.dart';
import '../../../helpers/fake_offers.dart';

void main() {
  late FakeCouponsRepository coupons;

  Future<void> pumpApp(WidgetTester tester, FakeCouponsRepository fake) async {
    coupons = fake;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository(restoredUser: testConsumer)),
          locationServiceProvider.overrideWithValue(FakeLocationService(initial: LocationAccess.granted)),
          offersRepositoryProvider.overrideWithValue(FakeOffersRepository()),
          offersViewProvider.overrideWith(ListFirstView.new),
          couponsRepositoryProvider.overrideWithValue(coupons),
        ],
        child: const GeopsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openBreadOffer(WidgetTester tester) async {
    await tester.tap(find.text('Pan francés 2x1'));
    await tester.pumpAndSettle();
  }

  testWidgets('claiming a coupon opens the code with its QR', (tester) async {
    await pumpApp(tester, FakeCouponsRepository());
    await openBreadOffer(tester);

    expect(find.text('Cupones'), findsOneWidget);
    expect(find.textContaining('Quedan 12'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('coupon.claim.c-1')));
    await tester.tap(find.byKey(const Key('coupon.claim.c-1')));
    await tester.pumpAndSettle();

    expect(coupons.claims, ['c-1']);
    expect(find.text('K7QM-4XPA'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.textContaining('Muestra este código en caja'), findsOneWidget);
  });

  testWidgets('an offer without coupons shows no coupon section', (tester) async {
    await pumpApp(tester, FakeCouponsRepository(available: []));
    await openBreadOffer(tester);

    expect(find.text('Cupones'), findsNothing);
  });

  testWidgets('claiming twice explains where the coupon is', (tester) async {
    await pumpApp(
      tester,
      FakeCouponsRepository(
        claimFailure: const ApiFailure(statusCode: 409, code: 'COUPON_LIMIT_REACHED', message: 'Limit'),
      ),
    );
    await openBreadOffer(tester);

    await tester.ensureVisible(find.byKey(const Key('coupon.claim.c-1')));
    await tester.tap(find.byKey(const Key('coupon.claim.c-1')));
    await tester.pumpAndSettle();

    expect(find.text('Ya obtuviste este cupón. Lo encuentras en Mis cupones.'), findsOneWidget);
  });

  testWidgets('my coupons lists usable codes first; used ones show no QR', (tester) async {
    await pumpApp(
      tester,
      FakeCouponsRepository(
        mine: [
          userCoupon(id: 'uc-old', code: 'AAAA2222', status: UserCouponStatus.redeemed),
          userCoupon(id: 'uc-new', code: 'BBBB3333'),
        ],
      ),
    );

    await tester.tap(find.byKey(const Key('offers.myCoupons')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Listo para usar'), findsOneWidget);
    expect(find.textContaining('Canjeado'), findsOneWidget);
    expect(
      tester.getTopLeft(find.textContaining('Listo para usar')).dy,
      lessThan(tester.getTopLeft(find.textContaining('Canjeado')).dy),
    );

    await tester.tap(find.textContaining('Canjeado'));
    await tester.pumpAndSettle();

    expect(find.text('AAAA-2222'), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
    expect(find.textContaining('Canjeado el'), findsOneWidget);
  });
}
