import 'package:flutter/material.dart';

/// Pantalla protegida: solo se llega aquí tras una autenticación exitosa.
///
/// Simula un caso de uso real (app bancaria, gestor de contraseñas, notas
/// privadas…). El contenido es de ejemplo.
class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bóveda segura')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Icon(Icons.verified_user_rounded, size: 80, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            '¡Identidad verificada!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          const _SecretTile(icon: Icons.account_balance, title: 'Saldo disponible', value: r'$ 1.250.000'),
          const _SecretTile(icon: Icons.key, title: 'Contraseña Wi-Fi', value: 'Fl#tt3r-2026'),
          const _SecretTile(icon: Icons.note_alt, title: 'Nota privada', value: 'Entregar el video el lunes 12 antes de las 11:59 p. m.'),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.lock),
            label: const Text('Cerrar bóveda'),
          ),
        ],
      ),
    );
  }
}

class _SecretTile extends StatelessWidget {
  const _SecretTile({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
