import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../coupons/presentation/coupon_labels.dart';
import '../../domain/entities/business_coupons.dart';
import '../providers/business_providers.dart';

/// The coupons of one offer, with their counts, and a button to issue a new one.
class OfferCouponsSection extends ConsumerWidget {
  const OfferCouponsSection({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(businessCouponsProvider).value ?? const <ProviderCoupon>[];
    final coupons = all.where((coupon) => coupon.offerId == offerId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 40),
        Text('Cupones de esta oferta', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (coupons.isEmpty) const Text('Crea un cupón para que los clientes lo guarden y lo canjeen en tu local.'),
        for (final coupon in coupons)
          Card(
            child: ListTile(
              title: Text(coupon.title),
              subtitle: Text(
                [
                  discountLabel(coupon.discountType, coupon.discountValue),
                  '${coupon.claimedCount} obtenidos',
                  '${coupon.redeemedCount} canjeados',
                  if (coupon.remaining != null) 'quedan ${coupon.remaining}',
                ].join(' · '),
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('offer.newCoupon'),
          onPressed: () => context.push(AppRoutes.newCoupon(offerId)),
          icon: const Icon(Icons.add),
          label: const Text('Crear cupón'),
        ),
      ],
    );
  }
}
