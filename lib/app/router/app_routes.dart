/// Route paths in one place, so screens never hard-code strings.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  /// Consumer home (offers map from Day 2).
  static const String home = '/home';

  static String offerDetail(String offerId) => '$home/offers/$offerId';

  /// Provider home (business panel from Day 2).
  static const String business = '/business';

  static const Set<String> publicRoutes = {login, register};
}
