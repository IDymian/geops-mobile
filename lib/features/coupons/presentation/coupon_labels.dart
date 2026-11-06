import '../../../core/errors/failure.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/coupon.dart';

/// `10% de descuento` or `S/ 2.00 de descuento`.
String discountLabel(DiscountType type, double value) => switch (type) {
  DiscountType.percent => '${value % 1 == 0 ? value.toInt() : value}% de descuento',
  DiscountType.fixed => '${Formatters.price(value)} de descuento',
};

String statusLabel(UserCouponStatus status) => switch (status) {
  UserCouponStatus.claimed => 'Listo para usar',
  UserCouponStatus.redeemed => 'Canjeado',
  UserCouponStatus.expired => 'Vencido',
};

String couponsFailureMessage(Object error) => switch (error) {
  NetworkFailure() => 'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
  ApiFailure(code: 'COUPON_LIMIT_REACHED') => 'Ya obtuviste este cupón. Lo encuentras en Mis cupones.',
  ApiFailure(code: 'COUPON_SOLD_OUT') => 'Se agotaron los cupones de esta oferta.',
  ApiFailure(code: 'COUPON_UNAVAILABLE' || 'COUPON_NOT_FOUND' || 'OFFER_NOT_FOUND') =>
    'Este cupón ya no está disponible.',
  _ => 'Algo salió mal. Inténtalo de nuevo.',
};
