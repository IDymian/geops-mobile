import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/user.dart';
import 'app_routes.dart';

/// Decides where the user may be, based on the session:
/// - restoring the session (or offline on start) -> splash
/// - signed out -> only login / register
/// - signed in -> only the home of their role
///
/// Returns `null` to stay on [location].
String? authRedirect(AsyncValue<User?> session, String location) {
  if (session.isLoading || session.hasError) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final user = session.value;
  if (user == null) {
    return AppRoutes.publicRoutes.contains(location) ? null : AppRoutes.login;
  }

  final home = switch (user.role) {
    UserRole.consumer => AppRoutes.home,
    UserRole.provider => AppRoutes.business,
  };
  return location.startsWith(home) ? null : home;
}
