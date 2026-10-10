import 'package:flutter/material.dart';

import '../controllers/biometric_controller.dart';
import '../models/auth_result.dart';
import '../widgets/auth_result_banner.dart';
import '../widgets/biometric_status_card.dart';
import '../widgets/web_unsupported_card.dart';
import 'vault_screen.dart';

/// Pantalla principal: muestra qué soporta el dispositivo y permite
/// autenticarse para entrar a la "bóveda segura".
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controllerFactory});

  /// Fábrica inyectada desde `app.dart` (ver `main.dart` y `app.dart`).
  final BiometricController Function() controllerFactory;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// `WidgetsBindingObserver` nos avisa cuando la app vuelve a primer plano.
/// Si el usuario fue a Ajustes a registrar su huella (o a activar Face ID),
/// refrescamos el estado automáticamente al regresar.
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final BiometricController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controllerFactory();
    _controller.loadStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_controller.isAuthenticating) {
      _controller.loadStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onAuthenticatePressed() async {
    final result = await _controller.authenticate();
    if (!mounted) return;

    // `switch` exhaustivo sobre la clase sealed: éxito o fallo, sin olvidos.
    switch (result) {
      case AuthSuccess():
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const VaultScreen()),
        );
        _controller.clearResult();
      case AuthFailure():
        // El banner de error ya se muestra en pantalla; no navegamos.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autenticación biométrica'),
        actions: [
          IconButton(
            tooltip: 'Volver a consultar el dispositivo',
            icon: const Icon(Icons.refresh),
            onPressed: _controller.loadStatus,
          ),
        ],
      ),
      // ListenableBuilder redibuja solo esta parte cuando el controlador
      // llama a notifyListeners().
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final status = _controller.status;

          if (_controller.isLoadingStatus && status == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _Header(),
              const SizedBox(height: 16),
              if (status != null && !status.isPlatformSupported)
                const WebUnsupportedCard()
              else if (status != null)
                BiometricStatusCard(status: status),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Solo biometría'),
                subtitle: Text(
                  _controller.biometricOnly
                      ? 'Únicamente huella o rostro'
                      : 'Se permite PIN, patrón o contraseña como respaldo',
                ),
                value: _controller.biometricOnly,
                onChanged: _controller.isAuthenticating
                    ? null
                    : _controller.setBiometricOnly,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: (status?.canAuthenticate ?? false) &&
                        !_controller.isAuthenticating
                    ? _onAuthenticatePressed
                    : null,
                icon: _controller.isAuthenticating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.fingerprint),
                label: const Text('Abrir bóveda segura'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 16),
              if (_controller.lastResult case final AuthFailure failure)
                AuthResultBanner(failure: failure),
            ],
          );
        },
      ),
    );
  }
}

/// Encabezado ilustrativo.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(Icons.lock_person_rounded, size: 72, color: colors.primary),
        const SizedBox(height: 8),
        Text(
          'Protege tu información con tu huella o tu rostro',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
