import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../failure_messages.dart';
import '../providers/auth_controller.dart';
import '../validators.dart';
import '../widgets/form_error_banner.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.consumer;
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _fieldErrors = const {});
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(email: _email.text, password: _password.text, fullName: _fullName.text, role: _role);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = authFailureMessage(failure);
        if (failure is ApiFailure) _fieldErrors = failure.fieldErrors;
      });
      // Shows the server-side field errors under each field.
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Local rule first; if it passes, the error the API returned for that field (if any).
  FormFieldValidator<String> _withServerError(String field, FormFieldValidator<String> local) =>
      (value) => local(value) ?? _fieldErrors[field];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.login)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('¿Cómo usarás GeoPS?', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    SegmentedButton<UserRole>(
                      key: const Key('register.role'),
                      segments: const [
                        ButtonSegment(
                          value: UserRole.consumer,
                          icon: Icon(Icons.local_offer_outlined),
                          label: Text('Busco ofertas'),
                        ),
                        ButtonSegment(
                          value: UserRole.provider,
                          icon: Icon(Icons.storefront_outlined),
                          label: Text('Tengo un negocio'),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: _submitting ? null : (selection) => setState(() => _role = selection.first),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('register.fullName'),
                      controller: _fullName,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                      validator: _withServerError('fullName', AuthValidators.fullName),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('register.email'),
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Correo', prefixIcon: Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: _withServerError('email', AuthValidators.email),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('register.password'),
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        helperText: 'Mínimo 8 caracteres, con letras y números',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: _withServerError('password', AuthValidators.newPassword),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[FormErrorBanner(_error!), const SizedBox(height: 16)],
                    FilledButton(
                      key: const Key('register.submit'),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Crear cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
