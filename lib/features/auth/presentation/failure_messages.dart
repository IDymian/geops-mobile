import '../../../core/errors/failure.dart';

/// Spanish messages for the auth errors the API can return.
String authFailureMessage(Failure failure) => switch (failure) {
  NetworkFailure() => 'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
  ApiFailure(code: 'AUTH_INVALID_CREDENTIALS') => 'Correo o contraseña incorrectos.',
  ApiFailure(code: 'EMAIL_ALREADY_REGISTERED') => 'Ya existe una cuenta con este correo.',
  ApiFailure(code: 'RATE_LIMITED') => 'Demasiados intentos. Espera un minuto e inténtalo otra vez.',
  ApiFailure(code: 'VALIDATION_FAILED') => 'Revisa los datos del formulario.',
  ApiFailure(code: 'PASSWORD_TOO_LONG') => 'La contraseña es demasiado larga.',
  _ => 'Algo salió mal. Inténtalo de nuevo.',
};
