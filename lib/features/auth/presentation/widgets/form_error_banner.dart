import 'package:flutter/material.dart';

/// Error shown above a form's submit button.
class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: colors.errorContainer, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
            ),
          ],
        ),
      ),
    );
  }
}
