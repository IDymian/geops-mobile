import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/business_coupons.dart';
import '../business_failure_messages.dart';
import '../providers/business_providers.dart';
import '../widgets/daily_activity_chart.dart';

/// Business dashboard: headline numbers, the last 7 days and the best offers.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(businessStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: stats.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(businessFailureMessage(error)),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: () => ref.invalidate(businessStatsProvider), child: const Text('Reintentar')),
            ],
          ),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(businessStatsProvider.future),
          child: _StatsView(stats: stats),
        ),
      ),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView({required this.stats});

  final BusinessStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: [
            _StatTile(
              key: const Key('stats.liveOffers'),
              label: 'Ofertas activas',
              value: '${stats.liveOffers}',
              detail: 'de ${stats.totalOffers}',
            ),
            _StatTile(key: const Key('stats.claimed'), label: 'Cupones obtenidos', value: '${stats.couponsClaimed}'),
            _StatTile(key: const Key('stats.redeemed'), label: 'Cupones canjeados', value: '${stats.couponsRedeemed}'),
            _StatTile(key: const Key('stats.rate'), label: 'Tasa de canje', value: '${stats.redemptionRate}%'),
          ],
        ),
        const SizedBox(height: 24),
        Text('Últimos 7 días', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        DailyActivityChart(days: stats.daily),
        ExpansionTile(
          key: const Key('stats.table'),
          tilePadding: EdgeInsets.zero,
          title: const Text('Ver como tabla'),
          children: [
            Table(
              children: [
                const TableRow(
                  children: [
                    Text('Día', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      'Obtenidos',
                      textAlign: TextAlign.end,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Canjeados',
                      textAlign: TextAlign.end,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                for (final day in stats.daily)
                  TableRow(
                    children: [
                      Text(DateFormat('dd/MM').format(day.date)),
                      Text('${day.claimed}', textAlign: TextAlign.end),
                      Text('${day.redeemed}', textAlign: TextAlign.end),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
        const SizedBox(height: 16),
        Text('Ofertas con más canjes', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (stats.topOffers.isEmpty)
          const Text('Cuando tus clientes usen cupones, verás aquí tus mejores ofertas.')
        else
          for (final (index, offer) in stats.topOffers.indexed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(offer.title),
              subtitle: Text('${offer.redeemed} canjeados · ${offer.claimed} obtenidos'),
            ),
      ],
    );
  }
}

/// A headline number: the hero value large, its label small and muted.
class _StatTile extends StatelessWidget {
  const _StatTile({super.key, required this.label, required this.value, this.detail});

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: theme.textTheme.labelMedium?.copyWith(color: muted)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: theme.textTheme.headlineSmall),
                if (detail != null) ...[
                  const SizedBox(width: 6),
                  Text(detail!, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
