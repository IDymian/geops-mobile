import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/business_repository_impl.dart';
import '../../domain/entities/business.dart';
import '../business_failure_messages.dart';
import '../providers/business_providers.dart';

/// One of the provider's offers, with its status and a switch to pause or reactivate it.
class ManagedOfferTile extends ConsumerStatefulWidget {
  const ManagedOfferTile({super.key, required this.offer, required this.onTap});

  final ManagedOffer offer;
  final VoidCallback onTap;

  @override
  ConsumerState<ManagedOfferTile> createState() => _ManagedOfferTileState();
}

class _ManagedOfferTileState extends ConsumerState<ManagedOfferTile> {
  bool _saving = false;

  Future<void> _setActive(bool active) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(businessRepositoryProvider)
          .updateOffer(widget.offer.id, widget.offer.toInput().copyWith(active: active));
      ref.invalidate(myOffersProvider);
      messenger.showSnackBar(SnackBar(content: Text(active ? 'Oferta reactivada' : 'Oferta pausada')));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(businessFailureMessage(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final status = offer.statusAt(ref.watch(clockProvider)());

    return Card(
      child: ListTile(
        onTap: widget.onTap,
        title: Text(offer.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              _StatusChip(status),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${Formatters.price(offer.offerPrice)} · ${offer.category.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // An expired offer cannot be reactivated: it has to be edited with a new end date.
        trailing: status == OfferStatus.expired
            ? null
            : Switch(key: Key('offer.toggle.${offer.id}'), value: offer.active, onChanged: _saving ? null : _setActive),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final OfferStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (status) {
      OfferStatus.live => ('Activa', colors.primaryContainer, colors.onPrimaryContainer),
      OfferStatus.scheduled => ('Programada', colors.tertiaryContainer, colors.onTertiaryContainer),
      OfferStatus.paused => ('Pausada', colors.surfaceContainerHighest, colors.onSurfaceVariant),
      OfferStatus.expired => ('Vencida', colors.errorContainer, colors.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
    );
  }
}
