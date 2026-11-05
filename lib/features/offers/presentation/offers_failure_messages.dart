import '../../../core/errors/failure.dart';

String offersFailureMessage(Object error) => switch (error) {
  NetworkFailure() => 'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
  ApiFailure(code: 'OFFER_NOT_FOUND') => 'Esta oferta ya no está disponible.',
  _ => 'No pudimos cargar las ofertas. Inténtalo de nuevo.',
};
