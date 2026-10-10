import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../models/biometric_kind.dart';
import 'biometric_platform.dart';

/// Implementación REAL del acceso a la plataforma usando el paquete `local_auth`.
///
/// Es un "adaptador" delgado: traduce las llamadas de nuestra interfaz a las
/// del plugin, que a su vez habla con:
///   - Android → BiometricPrompt (AndroidX Biometric)
///   - iOS     → LocalAuthentication framework (LAContext)
///   - Windows → Windows Hello
class LocalAuthPlatform implements BiometricPlatform {
  LocalAuthPlatform(this._auth);

  final LocalAuthentication _auth;

  /// `local_auth` soporta Android, iOS, macOS y Windows.
  /// En Web y Linux NO existe implementación, así que lo detectamos ANTES de
  /// llamar al plugin (si no, lanzaría `MissingPluginException`).
  ///
  /// Usamos `kIsWeb` y `defaultTargetPlatform` en lugar de `dart:io`, porque
  /// `dart:io` no compila para Web.
  @override
  bool get isPlatformSupported {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows =>
        true,
      _ => false,
    };
  }

  /// ¿El dispositivo tiene biometría O credencial (PIN/patrón/contraseña)?
  @override
  Future<bool> isDeviceSupported() => _auth.isDeviceSupported();

  /// ¿Existe hardware biométrico que se pueda consultar?
  @override
  Future<bool> canCheckBiometrics() => _auth.canCheckBiometrics;

  /// Lista de biometrías registradas, convertidas a nuestro enum de dominio.
  @override
  Future<List<BiometricKind>> getEnrolledBiometrics() async {
    final types = await _auth.getAvailableBiometrics();
    return types.map(_toDomain).toList(growable: false);
  }

  @override
  Future<bool> authenticate({
    required String reason,
    required bool biometricOnly,
  }) {
    return _auth.authenticate(
      // Texto que aparece dentro del diálogo nativo.
      localizedReason: reason,
      options: AuthenticationOptions(
        // true  → solo huella/rostro.
        // false → permite PIN/patrón como alternativa.
        biometricOnly: biometricOnly,
        // Si la app pasa a segundo plano, reintenta al volver en vez de fallar.
        stickyAuth: true,
        // Deja que el sistema muestre sus propios diálogos de ayuda
        // (p. ej. "Ve a Ajustes para registrar una huella").
        useErrorDialogs: true,
      ),
    );
  }

  @override
  Future<void> stopAuthentication() async {
    await _auth.stopAuthentication();
  }

  /// Traduce el tipo del plugin a nuestro tipo de dominio.
  BiometricKind _toDomain(BiometricType type) {
    return switch (type) {
      BiometricType.fingerprint => BiometricKind.fingerprint,
      BiometricType.face => BiometricKind.face,
      BiometricType.iris => BiometricKind.iris,
      BiometricType.strong => BiometricKind.strong,
      BiometricType.weak => BiometricKind.weak,
    };
  }
}
