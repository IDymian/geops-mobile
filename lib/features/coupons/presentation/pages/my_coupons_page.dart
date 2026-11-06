import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/coupon.dart';
import '../coupon_labels.dart';
import '../providers/coupons_providers.dart';

class MyCouponsPage extends ConsumerWidget {
  const MyCouponsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(myCouponsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis cupones')),
      body: coupons.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(couponsFailureMessage(error)),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: () => ref.invalidate(myCouponsProvider), child: const Text('Reintentar')),
            ],
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aún no tienes cupones. Busca una oferta con cupón y tócalo para obtenerlo.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // Ready-to-use codes first, then the rest, each group newest first.
          final sorted = [
            ...list.where((c) => c.status == UserCouponStatus.claimed),
            ...list.where((c) => c.status != UserCouponStatus.claimed),
          ];
          return RefreshIndicator(
            onRefresh: () => ref.refresh(myCouponsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _CouponTile(coupon: sorted[i]),
            ),
          );
        },
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({required this.coupon});

  final UserCoupon coupon;

  @override
  Widget build(BuildContext context) {
    final usable = coupon.status == UserCouponStatus.claimed;
    return Opacity(
      opacity: usable ? 1 : 0.6,
      child: Card(
        child: ListTile(
          onTap: () => context.push(AppRoutes.myCoupon(coupon.id)),
          leading: Icon(usable ? Icons.qr_code_2 : Icons.check_circle_outline),
          title: Text(coupon.title),
          subtitle: Text('${coupon.businessName} · ${statusLabel(coupon.status)}'),
          trailing: usable ? Text(Formatters.endsAt(coupon.validUntil)) : null,
        ),
      ),
    );
  }
}
