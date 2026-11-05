import '../../../core/errors/failure.dart';

String businessFailureMessage(Object error) => switch (error) {
  NetworkFailure() => 'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
  ApiFailure(code: 'BUSINESS_NOT_FOUND') => 'Primero registra tu negocio.',
  ApiFailure(code: 'OFFER_NOT_FOUND') => 'Esta oferta ya no existe.',
  ApiFailure(code: 'CATEGORY_NOT_FOUND') => 'Elige una categoría válida.',
  ApiFailure(code: 'OFFER_INVALID_PERIOD') => 'La oferta debe terminar después de empezar.',
  ApiFailure(code: 'OFFER_INVALID_PRICE') => 'El precio de oferta no puede ser mayor al precio normal.',
  ApiFailure(code: 'VALIDATION_FAILED', :final fieldErrors) when fieldErrors.containsKey('endsAt') =>
    'La fecha de fin debe ser futura.',
  ApiFailure(code: 'VALIDATION_FAILED') => 'Revisa los datos del formulario.',
  _ => 'Algo salió mal. Inténtalo de nuevo.',
};
