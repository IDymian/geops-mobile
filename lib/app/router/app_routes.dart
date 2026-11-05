/// Route paths in one place, so screens never hard-code strings.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  /// Consumer home: offers near the user.
  static const String home = '/home';

  static String offerDetail(String offerId) => '$home/offers/$offerId';

  /// Provider home: the business panel.
  static const String business = '/business';

  static const String businessProfile = '$business/profile';

  static const String newOffer = '$business/offers/new';

  static String editOffer(String offerId) => '$business/offers/$offerId';

  static const Set<String> publicRoutes = {login, register};
}
