import 'package:flutter/material.dart';

import '../models/biometric_status.dart';

/// Tarjeta que muestra, de forma visual, qué soporta el dispositivo.
/// Muy útil en el video para explicar cada método de `local_auth`.
class BiometricStatusCard extends StatelessWidget {
  const BiometricStatusCard({super.key, required this.status});

  final BiometricStatus status;

  @override
  Widget build(BuildContext context) {
    final enrolled = status.enrolledBiometrics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado del dispositivo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _CheckRow(
              ok: status.isDeviceSupported,
              text: 'Bloqueo seguro configurado (isDeviceSupported)',
            ),
            _CheckRow(
              ok: status.canCheckBiometrics,
              text: 'Hardware biométrico (canCheckBiometrics)',
            ),
            _CheckRow(
              ok: enrolled.isNotEmpty,
              text: enrolled.isEmpty
                  ? 'Sin biometrías registradas (getAvailableBiometrics)'
                  : 'Registradas: ${enrolled.map((k) => k.label).join(', ')}',
            ),
            if (status.hasHardwareButNothingEnrolled) ...[
              const SizedBox(height: 8),
              Text(
                'Tu teléfono tiene sensor, pero no has registrado huella ni rostro. '
                'Hazlo en Ajustes > Seguridad.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.ok, required this.text});

  final bool ok;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel,
            color: ok ? Colors.green : Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
