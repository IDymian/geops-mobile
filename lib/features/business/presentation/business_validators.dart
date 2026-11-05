/// Form validators for the business panel. They mirror the API rules
/// (`BusinessRequest` / `OfferRequest`); the API still validates everything.
abstract final class BusinessValidators {
  static final _phone = RegExp(r'^[0-9+ ()-]{6,20}$');
  static final _price = RegExp(r'^\d{1,8}([.,]\d{1,2})?$');

  static String? businessName(String? value) => _required(value, 'Ingresa el nombre del negocio', max: 120);

  static String? address(String? value) => _required(value, 'Ingresa la dirección', max: 200);

  static String? phone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    return _phone.hasMatch(phone) ? null : 'Ingresa un teléfono válido';
  }

  static String? description(String? value) => (value?.trim().length ?? 0) > 1000 ? 'Máximo 1000 caracteres' : null;

  static String? offerTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.length < 3) return 'Escribe un título de al menos 3 caracteres';
    if (title.length > 120) return 'Máximo 120 caracteres';
    return null;
  }

  static String? offerPrice(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Ingresa el precio de la oferta';
    return parsePrice(value) == null ? 'Usa un monto como 12.50' : null;
  }

  /// The original price is optional, but if present it cannot be lower than the offer price.
  static String? originalPrice(String? value, {required String? offerPrice}) {
    if ((value?.trim() ?? '').isEmpty) return null;
    final original = parsePrice(value);
    if (original == null) return 'Usa un monto como 20.00';
    final offer = parsePrice(offerPrice);
    if (offer != null && original < offer) return 'Debe ser mayor o igual al precio de oferta';
    return null;
  }

  /// `12`, `12.5` and `12,50` are all valid; at most two decimals.
  static double? parsePrice(String? value) {
    final text = value?.trim() ?? '';
    if (!_price.hasMatch(text)) return null;
    return double.parse(text.replaceAll(',', '.'));
  }

  static String? _required(String? value, String message, {required int max}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return message;
    if (text.length > max) return 'Máximo $max caracteres';
    return null;
  }
}
