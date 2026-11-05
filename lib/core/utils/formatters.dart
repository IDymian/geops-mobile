import 'package:intl/intl.dart';

/// Spanish (Peru) display formats.
abstract final class Formatters {
  static final _date = DateFormat('dd/MM');
  static final _time = DateFormat('HH:mm');

  /// `350 m`, `1,5 km`, `12 km`.
  static String distance(int meters) {
    if (meters < 1000) return '$meters m';
    final km = meters / 1000;
    final text = km < 10 ? km.toStringAsFixed(1) : km.round().toString();
    return '${text.replaceAll('.', ',')} km';
  }

  /// `S/ 5.00` (Peruvian soles).
  static String price(double amount) => 'S/ ${amount.toStringAsFixed(2)}';

  /// `Vence hoy a las 18:00` or `Vence el 12/11`.
  static String endsAt(DateTime endsAt, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final sameDay = endsAt.year == today.year && endsAt.month == today.month && endsAt.day == today.day;
    return sameDay ? 'Vence hoy a las ${_time.format(endsAt)}' : 'Vence el ${_date.format(endsAt)}';
  }
}
