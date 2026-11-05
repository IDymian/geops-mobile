import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

enum UserRole { consumer, provider }

/// The signed-in user, as the rest of the app sees it.
@freezed
abstract class User with _$User {
  const factory User({required String id, required String email, required String fullName, required UserRole role}) =
      _User;
}
