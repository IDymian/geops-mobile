import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/offer.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, required this.onTap});

  final NearbyOffer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: const Icon(Icons.local_offer_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('${offer.business.name} · ${Formatters.distance(offer.distanceMeters)}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          Formatters.price(offer.offerPrice),
                          style: theme.textTheme.titleMedium?.copyWith(color: colors.primary),
                        ),
                        if (offer.originalPrice != null)
                          Text(
                            Formatters.price(offer.originalPrice!),
                            style: const TextStyle(decoration: TextDecoration.lineThrough),
                          ),
                        if (offer.discountPercent != null && offer.discountPercent! > 0)
                          _Badge('-${offer.discountPercent}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(Formatters.endsAt(offer.endsAt), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: colors.tertiaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Text(
        text,
        style: TextStyle(color: colors.onTertiaryContainer, fontWeight: FontWeight.bold),
      ),
    );
  }
}
