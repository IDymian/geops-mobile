import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/coupons_repository_impl.dart';
import '../../domain/entities/coupon.dart';
import '../coupon_labels.dart';
import '../providers/coupons_providers.dart';

/// Coupons the consumer can claim for an offer. Hidden when there are none,
/// and never blocks the offer detail if it fails to load.
class AvailableCouponsSection extends ConsumerWidget {
  const AvailableCouponsSection({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(availableCouponsProvider(offerId)).value ?? const <AvailableCoupon>[];
    if (coupons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text('Cupones', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final coupon in coupons) _CouponCard(offerId: offerId, coupon: coupon),
      ],
    );
  }
}

class _CouponCard extends ConsumerStatefulWidget {
  const _CouponCard({required this.offerId, required this.coupon});

  final String offerId;
  final AvailableCoupon coupon;

  @override
  ConsumerState<_CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends ConsumerState<_CouponCard> {
  bool _claiming = false;

  Future<void> _claim() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _claiming = true);
    try {
      final claimed = await ref.read(couponsRepositoryProvider).claim(widget.coupon.id);
      ref
        ..invalidate(availableCouponsProvider(widget.offerId))
        ..invalidate(myCouponsProvider);
      if (mounted) await context.push(AppRoutes.myCoupon(claimed.id));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(couponsFailureMessage(error))));
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupon = widget.coupon;
    final remaining = coupon.remaining;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            const Icon(Icons.confirmation_number_outlined),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coupon.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    [
                      discountLabel(coupon.discountType, coupon.discountValue),
                      if (remaining != null) 'Quedan $remaining',
                      'Hasta el ${Formatters.dateTime(coupon.validUntil)}',
                    ].join(' · '),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              key: Key('coupon.claim.${coupon.id}'),
              // The app theme makes buttons full-width; inside a row it must size to its label.
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: _claiming ? null : _claim,
              child: const Text('Obtener'),
            ),
          ],
        ),
      ),
    );
  }
}
