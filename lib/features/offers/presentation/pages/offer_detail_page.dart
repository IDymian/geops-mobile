import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../coupons/presentation/widgets/available_coupons_section.dart';
import '../offers_failure_messages.dart';
import '../providers/offers_providers.dart';

class OfferDetailPage extends ConsumerWidget {
  const OfferDetailPage({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(offerDetailProvider(offerId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Oferta')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(offersFailureMessage(error), textAlign: TextAlign.center),
          ),
        ),
        data: (offer) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Chip(label: Text(offer.category.name)),
            const SizedBox(height: 8),
            Text(offer.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  Formatters.price(offer.offerPrice),
                  style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                if (offer.originalPrice != null)
                  Text(
                    Formatters.price(offer.originalPrice!),
                    style: theme.textTheme.titleMedium?.copyWith(decoration: TextDecoration.lineThrough),
                  ),
                if (offer.discountPercent != null && offer.discountPercent! > 0) ...[
                  const SizedBox(width: 12),
                  Text('-${offer.discountPercent}%', style: theme.textTheme.titleMedium),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(Formatters.endsAt(offer.endsAt)),
            if (offer.description != null) ...[const SizedBox(height: 16), Text(offer.description!)],
            AvailableCouponsSection(offerId: offer.id),
            const Divider(height: 40),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.storefront_outlined),
              title: Text(offer.business.name),
              subtitle: Text(offer.business.address),
            ),
            if (offer.business.phone != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined),
                title: Text(offer.business.phone!),
              ),
          ],
        ),
      ),
    );
  }
}
