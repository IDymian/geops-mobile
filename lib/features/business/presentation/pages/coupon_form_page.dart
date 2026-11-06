import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/widgets/form_error_banner.dart';
import '../../../coupons/domain/entities/coupon.dart';
import '../../data/business_repository_impl.dart';
import '../../domain/entities/business_coupons.dart';
import '../business_failure_messages.dart';
import '../business_validators.dart';
import '../providers/business_providers.dart';

/// Issues a coupon for one of the provider's offers. It lasts as long as the offer.
class CouponFormPage extends ConsumerStatefulWidget {
  const CouponFormPage({super.key, required this.offerId});

  final String offerId;

  @override
  ConsumerState<CouponFormPage> createState() => _CouponFormPageState();
}

class _CouponFormPageState extends ConsumerState<CouponFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _value = TextEditingController();
  final _stock = TextEditingController();
  DiscountType _type = DiscountType.percent;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _value.dispose();
    _stock.dispose();
    super.dispose();
  }

  String? _validateValue(String? text) {
    final value = BusinessValidators.parsePrice(text);
    if (value == null || value <= 0) return 'Ingresa un descuento mayor que cero';
    if (_type == DiscountType.percent && value > 100) return 'Máximo 100%';
    return null;
  }

  static String? _validateStock(String? text) {
    final stock = text?.trim() ?? '';
    if (stock.isEmpty) return null;
    final value = int.tryParse(stock);
    return (value == null || value <= 0) ? 'Usa un número entero, o déjalo vacío para no tener límite' : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final stock = _stock.text.trim();
      await ref
          .read(businessRepositoryProvider)
          .createCoupon(
            widget.offerId,
            CouponInput(
              title: _title.text,
              discountType: _type,
              discountValue: BusinessValidators.parsePrice(_value.text)!,
              stock: stock.isEmpty ? null : int.parse(stock),
            ),
          );
      ref.invalidate(businessCouponsProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Cupón creado')));
      if (mounted) context.pop();
    } catch (error) {
      setState(() => _error = businessFailureMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo cupón')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              key: const Key('coupon.title'),
              controller: _title,
              decoration: const InputDecoration(labelText: 'Nombre del cupón', hintText: '10% extra pagando en tienda'),
              textCapitalization: TextCapitalization.sentences,
              validator: BusinessValidators.offerTitle,
            ),
            const SizedBox(height: 16),
            SegmentedButton<DiscountType>(
              key: const Key('coupon.type'),
              segments: const [
                ButtonSegment(value: DiscountType.percent, label: Text('Porcentaje')),
                ButtonSegment(value: DiscountType.fixed, label: Text('Monto en soles')),
              ],
              selected: {_type},
              onSelectionChanged: (selected) => setState(() => _type = selected.single),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('coupon.value'),
              controller: _value,
              decoration: InputDecoration(
                labelText: 'Descuento',
                prefixText: _type == DiscountType.fixed ? 'S/ ' : null,
                suffixText: _type == DiscountType.percent ? '%' : null,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validateValue,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('coupon.stock'),
              controller: _stock,
              decoration: const InputDecoration(
                labelText: 'Cantidad de cupones (opcional)',
                helperText: 'Vacío = sin límite. Cada cliente puede obtenerlo una vez.',
              ),
              keyboardType: TextInputType.number,
              validator: _validateStock,
            ),
            const SizedBox(height: 24),
            if (_error case final error?) ...[FormErrorBanner(error), const SizedBox(height: 16)],
            FilledButton(
              key: const Key('coupon.save'),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Crear cupón'),
            ),
          ],
        ),
      ),
    );
  }
}
