import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/core/utils/formatters.dart';

void main() {
  test('distance', () {
    expect(Formatters.distance(350), '350 m');
    expect(Formatters.distance(1500), '1,5 km');
    expect(Formatters.distance(12400), '12 km');
  });

  test('price in soles', () {
    expect(Formatters.price(5), 'S/ 5.00');
    expect(Formatters.price(12.5), 'S/ 12.50');
  });

  test('expiry', () {
    final now = DateTime(2026, 11, 5, 10);
    expect(Formatters.endsAt(DateTime(2026, 11, 5, 18), now: now), 'Vence hoy a las 18:00');
    expect(Formatters.endsAt(DateTime(2026, 11, 12, 18), now: now), 'Vence el 12/11');
  });
}
