import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/widgets/form_error_banner.dart';
import '../../../coupons/presentation/coupon_labels.dart';
import '../../data/business_repository_impl.dart';
import '../../domain/entities/business_coupons.dart';
import '../business_failure_messages.dart';
import '../providers/business_providers.dart';

/// The counter: the cashier types the customer's code and sees what to charge.
class RedeemPage extends ConsumerStatefulWidget {
  const RedeemPage({super.key});

  @override
  ConsumerState<RedeemPage> createState() => _RedeemPageState();
}

class _RedeemPageState extends ConsumerState<RedeemPage> {
  final _code = TextEditingController();
  bool _redeeming = false;
  String? _error;
  Redemption? _result;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    if (_code.text.trim().isEmpty) {
      setState(() => _error = 'Escribe el código que te muestra el cliente.');
      return;
    }
    setState(() {
      _redeeming = true;
      _error = null;
    });
    try {
      final result = await ref.read(businessRepositoryProvider).redeem(_code.text);
      ref
        ..invalidate(businessStatsProvider)
        ..invalidate(businessCouponsProvider);
      setState(() => _result = result);
    } catch (error) {
      setState(() => _error = businessFailureMessage(error));
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  void _next() => setState(() {
    _result = null;
    _error = null;
    _code.clear();
  });

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Canjear cupón')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: result != null
            ? [
                _RedemptionCard(result),
                const SizedBox(height: 24),
                FilledButton(key: const Key('redeem.next'), onPressed: _next, child: const Text('Canjear otro')),
              ]
            : [
                const Text('Pide al cliente que abra el cupón en su app y escribe el código que aparece bajo el QR.'),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('redeem.code'),
                  controller: _code,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 -]'))],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 3),
                  decoration: const InputDecoration(labelText: 'Código', hintText: 'K7QM-4XPA'),
                  onSubmitted: (_) => _redeem(),
                ),
                const SizedBox(height: 16),
                if (_error case final error?) ...[FormErrorBanner(error), const SizedBox(height: 16)],
                FilledButton(
                  key: const Key('redeem.submit'),
                  onPressed: _redeeming ? null : _redeem,
                  child: _redeeming
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Canjear'),
                ),
              ],
      ),
    );
  }
}

class _RedemptionCard extends StatelessWidget {
  const _RedemptionCard(this.result);

  final Redemption result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = result.customerFirstName;
    return Semantics(
      liveRegion: true,
      child: Card(
        color: colors.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: colors.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text('Cupón canjeado', style: theme.textTheme.titleLarge?.copyWith(color: colors.onPrimaryContainer)),
                ],
              ),
              const SizedBox(height: 12),
              if (name != null) Text('Cliente: $name'),
              Text('${result.couponTitle} · ${discountLabel(result.discountType, result.discountValue)}'),
              Text('Oferta: ${result.offerTitle} (${Formatters.price(result.offerPrice)})'),
              const SizedBox(height: 12),
              Text(
                'Cobra ${Formatters.price(result.finalPrice)}',
                key: const Key('redeem.finalPrice'),
                style: theme.textTheme.headlineSmall?.copyWith(color: colors.onPrimaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
