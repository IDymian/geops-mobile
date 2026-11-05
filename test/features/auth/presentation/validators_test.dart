import 'package:flutter_test/flutter_test.dart';
import 'package:geops_mobile/features/auth/presentation/validators.dart';

void main() {
  test('email', () {
    expect(AuthValidators.email(''), isNotNull);
    expect(AuthValidators.email('ana@'), isNotNull);
    expect(AuthValidators.email(' ana@example.com '), isNull);
  });

  test('new password mirrors the API rules', () {
    expect(AuthValidators.newPassword('short1'), isNotNull, reason: 'too short');
    expect(AuthValidators.newPassword('onlyletters'), isNotNull, reason: 'no digit');
    expect(AuthValidators.newPassword('12345678'), isNotNull, reason: 'no letter');
    expect(AuthValidators.newPassword('a1' * 33), isNotNull, reason: 'over 64 chars');
    expect(AuthValidators.newPassword('Contraseña1'), isNull, reason: 'accents count as letters');
  });

  test('full name', () {
    expect(AuthValidators.fullName('   '), isNotNull);
    expect(AuthValidators.fullName('Ana Torres'), isNull);
  });
}
