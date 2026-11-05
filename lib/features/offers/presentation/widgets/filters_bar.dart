import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../providers/offers_providers.dart';

/// Category chips and the search radius.
class FiltersBar extends ConsumerWidget {
  const FiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final controller = ref.read(searchFiltersProvider.notifier);
    final categories = ref.watch(categoriesProvider).value ?? const [];

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          PopupMenuButton<int>(
            key: const Key('filters.radius'),
            tooltip: 'Radio de búsqueda',
            initialValue: filters.radiusMeters,
            onSelected: controller.setRadius,
            itemBuilder: (context) => [
              for (final meters in SearchFilters.radiusOptions)
                PopupMenuItem(value: meters, child: Text('Hasta ${Formatters.distance(meters)}')),
            ],
            child: Chip(
              avatar: const Icon(Icons.radar, size: 18),
              label: Text(Formatters.distance(filters.radiusMeters)),
            ),
          ),
          const SizedBox(width: 8),
          for (final category in categories) ...[
            FilterChip(
              label: Text(category.name),
              selected: filters.categorySlug == category.slug,
              onSelected: (_) => controller.toggleCategory(category.slug),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
