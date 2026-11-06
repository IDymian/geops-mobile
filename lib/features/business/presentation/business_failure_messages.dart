import '../../../core/errors/failure.dart';

String businessFailureMessage(Object error) => switch (error) {
  NetworkFailure() => 'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
  ApiFailure(code: 'BUSINESS_NOT_FOUND') => 'Primero registra tu negocio.',
  ApiFailure(code: 'OFFER_NOT_FOUND') => 'Esta oferta ya no existe.',
  ApiFailure(code: 'CATEGORY_NOT_FOUND') => 'Elige una categoría válida.',
  ApiFailure(code: 'OFFER_INVALID_PERIOD') => 'La oferta debe terminar después de empezar.',
  ApiFailure(code: 'OFFER_INVALID_PRICE') => 'El precio de oferta no puede ser mayor al precio normal.',
  ApiFailure(code: 'COUPON_CODE_NOT_FOUND') => 'Este código no existe o no es de tu negocio.',
  ApiFailure(code: 'COUPON_ALREADY_REDEEMED') => 'Este código ya fue canjeado.',
  ApiFailure(code: 'COUPON_EXPIRED') => 'Este código ya venció.',
  ApiFailure(code: 'COUPON_INVALID_DISCOUNT') => 'El descuento no puede pasar del 100% ni del precio de la oferta.',
  ApiFailure(code: 'COUPON_INVALID_PERIOD') => 'La oferta ya terminó: extiende su fecha antes de crear cupones.',
  ApiFailure(code: 'VALIDATION_FAILED', :final fieldErrors) when fieldErrors.containsKey('endsAt') =>
    'La fecha de fin debe ser futura.',
  ApiFailure(code: 'VALIDATION_FAILED') => 'Revisa los datos del formulario.',
  _ => 'Algo salió mal. Inténtalo de nuevo.',
};
