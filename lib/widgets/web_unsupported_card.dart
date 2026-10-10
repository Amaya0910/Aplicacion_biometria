import 'package:flutter/material.dart';

/// Se muestra en Web (y Linux), donde `local_auth` no tiene implementación.
///
/// En lugar de que la app falle, explicamos la limitación y la alternativa
/// del navegador: WebAuthn / Passkeys.
class WebUnsupportedCard extends StatelessWidget {
  const WebUnsupportedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.public),
                const SizedBox(width: 8),
                Text('Biometría en la Web', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• El paquete local_auth NO tiene soporte para Web.\n'
              '• Los navegadores no dan acceso directo al sensor de huella o rostro.\n'
              '• La alternativa estándar es WebAuthn (navigator.credentials) / Passkeys: '
              'el navegador pide la huella o el rostro al sistema operativo y el sitio '
              'solo recibe una firma criptográfica, nunca el dato biométrico.\n'
              '• WebAuthn exige HTTPS (o localhost) y un servidor que valide la firma.',
            ),
          ],
        ),
      ),
    );
  }
}
