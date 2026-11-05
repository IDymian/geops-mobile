import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/features/business/presentation/business_validators.dart';

void main() {
  test('prices accept a dot or a comma and at most two decimals', () {
    expect(BusinessValidators.parsePrice('12'), 12);
    expect(BusinessValidators.parsePrice('12,5'), 12.5);
    expect(BusinessValidators.parsePrice('12.50'), 12.5);
    expect(BusinessValidators.parsePrice('12.505'), isNull);
    expect(BusinessValidators.parsePrice('-3'), isNull);
    expect(BusinessValidators.parsePrice('abc'), isNull);
  });

  test('original price is optional but cannot be below the offer price', () {
    expect(BusinessValidators.originalPrice('', offerPrice: '5'), isNull);
    expect(BusinessValidators.originalPrice('5', offerPrice: '5'), isNull);
    expect(BusinessValidators.originalPrice('4.99', offerPrice: '5'), isNotNull);
  });

  test('phone is optional and mirrors the API pattern', () {
    expect(BusinessValidators.phone(''), isNull);
    expect(BusinessValidators.phone('+51 987 654 321'), isNull);
    expect(BusinessValidators.phone('call me'), isNotNull);
  });

  test('offer title needs 3 to 120 characters', () {
    expect(BusinessValidators.offerTitle('2x1'), isNull);
    expect(BusinessValidators.offerTitle('ab'), isNotNull);
    expect(BusinessValidators.offerTitle('a' * 121), isNotNull);
  });
}
