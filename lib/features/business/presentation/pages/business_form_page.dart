import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/location/location_service.dart';
import '../../../auth/presentation/widgets/form_error_banner.dart';
import '../../data/business_repository_impl.dart';
import '../../domain/entities/business.dart';
import '../business_failure_messages.dart';
import '../business_validators.dart';
import '../providers/business_providers.dart';
import 'location_picker_page.dart';

/// Registers the business the first time, edits it afterwards.
class BusinessFormPage extends ConsumerStatefulWidget {
  const BusinessFormPage({super.key});

  @override
  ConsumerState<BusinessFormPage> createState() => _BusinessFormPageState();
}

class _BusinessFormPageState extends ConsumerState<BusinessFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final Business? _existing = ref.read(myBusinessProvider).value;
  late final _name = TextEditingController(text: _existing?.name);
  late final _description = TextEditingController(text: _existing?.description);
  late final _phone = TextEditingController(text: _existing?.phone);
  late final _address = TextEditingController(text: _existing?.address);
  late GeoPoint? _location = _existing?.location;

  bool _saving = false;
  bool _locating = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    final service = ref.read(locationServiceProvider);
    setState(() => _locating = true);
    try {
      final access = await service.requestAccess();
      if (access != LocationAccess.granted) {
        setState(() => _error = 'Activa el permiso de ubicación o elige el punto en el mapa.');
        return;
      }
      final here = await service.currentPosition();
      setState(() {
        _location = here;
        _error = null;
      });
    } catch (_) {
      setState(() => _error = 'No pudimos obtener tu ubicación. Elige el punto en el mapa.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickOnMap() async {
    final picked = await Navigator.of(context)
        .push<GeoPoint>(MaterialPageRoute(builder: (_) => LocationPickerPage(initial: _location)));
    if (picked != null) setState(() => _location = picked);
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    final location = _location;
    if (location == null) {
      setState(() => _error = 'Marca la ubicación de tu negocio.');
      return;
    }
    if (!valid) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(businessRepositoryProvider)
          .save(
            BusinessInput(
              name: _name.text,
              description: _description.text,
              phone: _phone.text,
              address: _address.text,
              location: location,
            ),
          );
      ref.invalidate(myBusinessProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Negocio guardado')));
      if (mounted) context.pop();
    } catch (error) {
      setState(() => _error = businessFailureMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = _location;
    return Scaffold(
      appBar: AppBar(title: Text(_existing == null ? 'Registrar negocio' : 'Editar negocio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              key: const Key('business.name'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre del negocio'),
              textCapitalization: TextCapitalization.words,
              validator: BusinessValidators.businessName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('business.address'),
              controller: _address,
              decoration: const InputDecoration(labelText: 'Dirección'),
              validator: BusinessValidators.address,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('business.phone'),
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
              keyboardType: TextInputType.phone,
              validator: BusinessValidators.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('business.description'),
              controller: _description,
              decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
              maxLines: 3,
              validator: BusinessValidators.description,
            ),
            const SizedBox(height: 24),
            Text('Ubicación', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              location == null
                  ? 'Los clientes encontrarán tus ofertas según este punto.'
                  : 'Lat ${location.latitude.toStringAsFixed(5)}, Lng ${location.longitude.toStringAsFixed(5)}',
              key: const Key('business.locationText'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('business.useCurrentLocation'),
                  onPressed: _locating ? null : _useCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Usar mi ubicación'),
                ),
                OutlinedButton.icon(
                  key: const Key('business.pickOnMap'),
                  onPressed: _pickOnMap,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Elegir en el mapa'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_error case final error?) ...[FormErrorBanner(error), const SizedBox(height: 16)],
            FilledButton(
              key: const Key('business.save'),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
