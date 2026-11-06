/// Route paths in one place, so screens never hard-code strings.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  /// Consumer home: offers near the user.
  static const String home = '/home';

  static String offerDetail(String offerId) => '$home/offers/$offerId';

  static const String myCoupons = '$home/coupons';

  static String myCoupon(String userCouponId) => '$myCoupons/$userCouponId';

  /// Provider home: the business panel.
  static const String business = '/business';

  static const String businessProfile = '$business/profile';

  static const String newOffer = '$business/offers/new';

  static String editOffer(String offerId) => '$business/offers/$offerId';

  static String newCoupon(String offerId) => '$business/offers/$offerId/coupons/new';

  static const String redeem = '$business/redeem';

  static const String stats = '$business/stats';

  static const Set<String> publicRoutes = {login, register};
}
