/// Form validators. They mirror the API rules so users get instant feedback;
/// the API still validates everything on its side.
abstract final class AuthValidators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _letter = RegExp(r'\p{L}', unicode: true);
  static final _digit = RegExp(r'\d');

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingresa tu correo';
    if (!_email.hasMatch(email)) return 'Ingresa un correo válido';
    return null;
  }

  static String? loginPassword(String? value) => (value == null || value.isEmpty) ? 'Ingresa tu contraseña' : null;

  static String? newPassword(String? value) {
    final password = value ?? '';
    if (password.length < 8 || password.length > 64) return 'Debe tener entre 8 y 64 caracteres';
    if (!_letter.hasMatch(password) || !_digit.hasMatch(password)) return 'Usa al menos una letra y un número';
    return null;
  }

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Ingresa tu nombre';
    if (name.length > 120) return 'Máximo 120 caracteres';
    return null;
  }
}
