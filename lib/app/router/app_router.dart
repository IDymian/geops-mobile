import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/business/presentation/pages/business_form_page.dart';
import '../../features/business/presentation/pages/business_home_page.dart';
import '../../features/business/presentation/pages/offer_form_page.dart';
import '../../features/coupons/presentation/pages/coupon_detail_page.dart';
import '../../features/coupons/presentation/pages/my_coupons_page.dart';
import '../../features/offers/presentation/pages/offer_detail_page.dart';
import '../../features/offers/presentation/pages/offers_home_page.dart';
import 'app_routes.dart';
import 'auth_redirect.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Re-runs the redirect whenever the session changes (login, logout, expiry).
  final sessionChanged = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => sessionChanged.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: sessionChanged,
    redirect: (context, state) => authRedirect(ref.read(authControllerProvider), state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashPage()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage()),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const OffersHomePage(),
        routes: [
          GoRoute(
            path: 'offers/:offerId',
            builder: (context, state) => OfferDetailPage(offerId: state.pathParameters['offerId']!),
          ),
          GoRoute(
            path: 'coupons',
            builder: (context, state) => const MyCouponsPage(),
            routes: [
              GoRoute(
                path: ':couponId',
                builder: (context, state) => CouponDetailPage(couponId: state.pathParameters['couponId']!),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.business,
        builder: (context, state) => const BusinessHomePage(),
        routes: [
          GoRoute(path: 'profile', builder: (context, state) => const BusinessFormPage()),
          // 'new' must come before ':offerId' so it is not read as an id.
          GoRoute(path: 'offers/new', builder: (context, state) => const OfferFormPage()),
          GoRoute(
            path: 'offers/:offerId',
            builder: (context, state) => OfferFormPage(offerId: state.pathParameters['offerId']),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    sessionChanged.dispose();
  });
  return router;
});
