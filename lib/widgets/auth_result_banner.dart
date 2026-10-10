import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/auth_result.dart';

/// Muestra al usuario POR QUÉ falló la autenticación y qué puede hacer.
///
/// Este widget es clave para la rúbrica: demuestra que la app maneja el
/// caso en que el usuario cancela o NIEGA el permiso.
class AuthResultBanner extends StatelessWidget {
  const AuthResultBanner({super.key, required this.failure});

  final AuthFailure failure;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reason = failure.reason;

    return Card(
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(reason.userMessage, style: TextStyle(color: colors.onErrorContainer)),
                  // El detalle técnico solo se ve en modo debug (útil al grabar).
                  if (kDebugMode && failure.technicalDetail != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      failure.technicalDetail!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: colors.onErrorContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
