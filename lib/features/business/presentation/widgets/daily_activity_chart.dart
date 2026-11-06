import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/business_coupons.dart';

/// Grouped bars per day: coupons claimed vs redeemed. Two series, so there is always
/// a legend; tapping a day shows its exact numbers, and a table view sits underneath.
///
/// Colors are categorical slots 1 and 2 (blue, orange), validated for color vision
/// deficiency and contrast against the light and dark surfaces.
class DailyActivityChart extends StatelessWidget {
  const DailyActivityChart({super.key, required this.days, this.height = 160});

  final List<DailyStat> days;
  final double height;

  static const _claimedLight = Color(0xFF2A78D6);
  static const _redeemedLight = Color(0xFFEB6834);
  static const _claimedDark = Color(0xFF3987E5);
  static const _redeemedDark = Color(0xFFD95926);

  static final _dayLabel = DateFormat('dd/MM');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final claimedColor = dark ? _claimedDark : _claimedLight;
    final redeemedColor = dark ? _redeemedDark : _redeemedLight;
    final maxValue = math.max(1, days.fold<int>(0, (max, d) => math.max(max, math.max(d.claimed, d.redeemed))));
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendItem(color: claimedColor, label: 'Obtenidos'),
            const SizedBox(width: 16),
            _LegendItem(color: redeemedColor, label: 'Canjeados'),
            const Spacer(),
            Text('máx. $maxValue', style: theme.textTheme.labelSmall?.copyWith(color: muted)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
          child: DecoratedBox(
            // Recessive baseline: the only axis line.
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in days)
                  Expanded(
                    child: Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      message: '${_dayLabel.format(day.date)}: ${day.claimed} obtenidos · ${day.redeemed} canjeados',
                      child: Semantics(
                        label: '${_dayLabel.format(day.date)}: ${day.claimed} obtenidos, ${day.redeemed} canjeados',
                        child: Container(
                          // Hit target is the whole column, wider and taller than the bars.
                          color: Colors.transparent,
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _Bar(value: day.claimed, max: maxValue, height: height, color: claimedColor),
                              const SizedBox(width: 2),
                              _Bar(value: day.redeemed, max: maxValue, height: height, color: redeemedColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final day in days)
              Expanded(
                child: Text(
                  _dayLabel.format(day.date),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.max, required this.height, required this.color});

  final int value;
  final int max;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Leave headroom so the tallest bar never touches the legend; zero stays flat on the baseline.
    final barHeight = value == 0 ? 0.0 : math.max(4.0, (height - 8) * value / max);
    return Container(
      width: 10,
      height: barHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 6),
      // Legend text stays in the normal ink; the swatch carries the identity.
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}
