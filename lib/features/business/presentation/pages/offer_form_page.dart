import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/widgets/form_error_banner.dart';
import '../../../offers/domain/entities/offer.dart';
import '../../../offers/presentation/providers/offers_providers.dart';
import '../../data/business_repository_impl.dart';
import '../../domain/entities/business.dart';
import '../business_failure_messages.dart';
import '../business_validators.dart';
import '../providers/business_providers.dart';

/// Publishes a new offer, or edits one when [offerId] is given.
class OfferFormPage extends ConsumerStatefulWidget {
  const OfferFormPage({super.key, this.offerId});

  final String? offerId;

  @override
  ConsumerState<OfferFormPage> createState() => _OfferFormPageState();
}

class _OfferFormPageState extends ConsumerState<OfferFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final ManagedOffer? _existing = _find(widget.offerId);
  late final _title = TextEditingController(text: _existing?.title);
  late final _description = TextEditingController(text: _existing?.description);
  late final _offerPrice = TextEditingController(text: _priceText(_existing?.offerPrice));
  late final _originalPrice = TextEditingController(text: _priceText(_existing?.originalPrice));
  late String? _categorySlug = _existing?.category.slug;
  late bool _active = _existing?.active ?? true;

  /// New offers last a week by default, until the end of that day.
  late DateTime _endsAt = _existing?.endsAt ?? _defaultEnd(ref.read(clockProvider)());

  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.offerId != null;

  ManagedOffer? _find(String? offerId) {
    if (offerId == null) return null;
    return ref.read(myOffersProvider).value?.where((offer) => offer.id == offerId).firstOrNull;
  }

  static String? _priceText(double? price) => price?.toStringAsFixed(2);

  static DateTime _defaultEnd(DateTime now) => DateTime(now.year, now.month, now.day + 7, 23, 59);

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _offerPrice.dispose();
    _originalPrice.dispose();
    super.dispose();
  }

  Future<void> _pickEnd() async {
    final now = ref.read(clockProvider)();
    final date = await showDatePicker(
      context: context,
      initialDate: _endsAt.isAfter(now) ? _endsAt : now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_endsAt));
    if (time == null) return;
    setState(() => _endsAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_endsAt.isAfter(ref.read(clockProvider)())) {
      setState(() => _error = 'La fecha de fin debe ser futura.');
      return;
    }

    final input = OfferInput(
      title: _title.text,
      description: _description.text,
      categorySlug: _categorySlug!,
      originalPrice: BusinessValidators.parsePrice(_originalPrice.text),
      offerPrice: BusinessValidators.parsePrice(_offerPrice.text)!,
      // Editing keeps the original start; a new offer starts now (API default).
      startsAt: _existing?.startsAt,
      endsAt: _endsAt,
      active: _active,
    );

    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(businessRepositoryProvider);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_isEdit) {
        await repository.updateOffer(widget.offerId!, input);
      } else {
        await repository.createOffer(input);
      }
      ref.invalidate(myOffersProvider);
      messenger.showSnackBar(SnackBar(content: Text(_isEdit ? 'Oferta actualizada' : 'Oferta publicada')));
      if (mounted) context.pop();
    } catch (error) {
      setState(() => _error = businessFailureMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEdit && _existing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Oferta')),
        body: const Center(child: Text('Esta oferta ya no existe.')),
      );
    }

    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar oferta' : 'Nueva oferta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              key: const Key('offer.title'),
              controller: _title,
              decoration: const InputDecoration(labelText: 'Título', hintText: '2x1 en pan francés'),
              textCapitalization: TextCapitalization.sentences,
              validator: BusinessValidators.offerTitle,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('offer.category'),
              initialValue: _categorySlug,
              decoration: InputDecoration(
                labelText: 'Categoría',
                helperText: categories.hasError ? 'No pudimos cargar las categorías' : null,
              ),
              items: [
                for (final category in categories.value ?? const <Category>[])
                  DropdownMenuItem(value: category.slug, child: Text(category.name)),
              ],
              onChanged: (slug) => setState(() => _categorySlug = slug),
              validator: (slug) => slug == null ? 'Elige una categoría' : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('offer.offerPrice'),
                    controller: _offerPrice,
                    decoration: const InputDecoration(labelText: 'Precio de oferta', prefixText: 'S/ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: BusinessValidators.offerPrice,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: const Key('offer.originalPrice'),
                    controller: _originalPrice,
                    decoration: const InputDecoration(labelText: 'Precio normal (opcional)', prefixText: 'S/ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => BusinessValidators.originalPrice(value, offerPrice: _offerPrice.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('offer.description'),
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Condiciones, horarios…',
              ),
              maxLines: 3,
              validator: BusinessValidators.description,
            ),
            const SizedBox(height: 8),
            ListTile(
              key: const Key('offer.endsAt'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Termina'),
              subtitle: Text(Formatters.dateTime(_endsAt)),
              onTap: _pickEnd,
            ),
            SwitchListTile(
              key: const Key('offer.active'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Visible para los clientes'),
              subtitle: const Text('Apágalo para pausar la oferta sin borrarla'),
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
            const SizedBox(height: 16),
            if (_error case final error?) ...[FormErrorBanner(error), const SizedBox(height: 16)],
            FilledButton(
              key: const Key('offer.save'),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEdit ? 'Guardar cambios' : 'Publicar oferta'),
            ),
          ],
        ),
      ),
    );
  }
}
