import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/coupon.dart';
import '../coupon_labels.dart';
import '../providers/coupons_providers.dart';

/// The code to show at the counter: a QR plus the same code as text, in case there is no scanner.
class CouponDetailPage extends ConsumerWidget {
  const CouponDetailPage({super.key, required this.couponId});

  final String couponId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(myCouponsProvider);
    final coupon = coupons.value?.where((c) => c.id == couponId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Tu cupón')),
      body: switch (coupon) {
        null when coupons.isLoading => const Center(child: CircularProgressIndicator()),
        null => const Center(child: Text('No encontramos este cupón.')),
        final coupon => _CouponView(coupon: coupon),
      },
    );
  }
}

class _CouponView extends StatelessWidget {
  const _CouponView({required this.coupon});

  final UserCoupon coupon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usable = coupon.status == UserCouponStatus.claimed;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(coupon.title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          discountLabel(coupon.discountType, coupon.discountValue),
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
          textAlign: TextAlign.center,
        ),
        Text(coupon.offerTitle, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (usable)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              // The QR needs a light background to be scanned, even in dark mode.
              color: Colors.white,
              child: QrImageView(
                key: const Key('coupon.qr'),
                data: coupon.code,
                size: 220,
                semanticsLabel: 'Código QR del cupón',
              ),
            ),
          )
        else
          Icon(
            coupon.status == UserCouponStatus.redeemed ? Icons.check_circle : Icons.event_busy,
            size: 96,
            color: theme.colorScheme.outline,
          ),
        const SizedBox(height: 16),
        SelectableText(
          Formatters.couponCode(coupon.code),
          key: const Key('coupon.code'),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 4, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 8),
        Text(switch (coupon.status) {
          UserCouponStatus.claimed =>
            'Muestra este código en caja. Válido hasta el ${Formatters.dateTime(coupon.validUntil)}.',
          UserCouponStatus.redeemed => 'Canjeado el ${Formatters.dateTime(coupon.redeemedAt ?? coupon.claimedAt)}.',
          UserCouponStatus.expired => 'Venció el ${Formatters.dateTime(coupon.validUntil)}.',
        }, textAlign: TextAlign.center),
        const Divider(height: 40),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.storefront_outlined),
          title: Text(coupon.businessName),
          subtitle: Text(coupon.businessAddress),
        ),
      ],
    );
  }
}
