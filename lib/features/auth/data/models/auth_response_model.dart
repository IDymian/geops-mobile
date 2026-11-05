import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

/// `user` object returned by the API.
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String fullName,
    required UserRoleModel role,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, Object?> json) => _$UserModelFromJson(json);

  User toEntity() => User(id: id, email: email, fullName: fullName, role: role.toEntity());
}

enum UserRoleModel {
  @JsonValue('CONSUMER')
  consumer,
  @JsonValue('PROVIDER')
  provider;

  static UserRoleModel fromEntity(UserRole role) => switch (role) {
    UserRole.consumer => UserRoleModel.consumer,
    UserRole.provider => UserRoleModel.provider,
  };

  UserRole toEntity() => switch (this) {
    UserRoleModel.consumer => UserRole.consumer,
    UserRoleModel.provider => UserRole.provider,
  };

  /// Value sent to the API.
  String get apiValue => name.toUpperCase();
}

/// Body of register / login / refresh responses.
@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required UserModel user,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, Object?> json) => _$AuthResponseModelFromJson(json);
}
