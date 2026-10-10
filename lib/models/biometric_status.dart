import 'biometric_kind.dart';

/// Fotografía del estado biométrico del dispositivo en un momento dado.
///
/// Es inmutable: si algo cambia, se pide un estado nuevo.
class BiometricStatus {
  const BiometricStatus({
    required this.isPlatformSupported,
    required this.isDeviceSupported,
    required this.canCheckBiometrics,
    required this.enrolledBiometrics,
  });

  /// Estado para plataformas donde `local_auth` no existe (Web, Linux).
  const BiometricStatus.unsupportedPlatform()
      : isPlatformSupported = false,
        isDeviceSupported = false,
        canCheckBiometrics = false,
        enrolledBiometrics = const [];

  /// ¿El paquete funciona en esta plataforma? (false en Web y Linux).
  final bool isPlatformSupported;

  /// ¿El dispositivo tiene algún mecanismo seguro (biometría o PIN/patrón)?
  final bool isDeviceSupported;

  /// ¿Hay hardware biométrico disponible para consultar?
  final bool canCheckBiometrics;

  /// Biometrías que el usuario YA registró en los ajustes del sistema.
  final List<BiometricKind> enrolledBiometrics;

  /// Hay hardware pero el usuario no ha registrado ninguna huella/rostro.
  bool get hasHardwareButNothingEnrolled =>
      canCheckBiometrics && enrolledBiometrics.isEmpty;

  /// Se puede intentar una autenticación (biométrica o con PIN).
  bool get canAuthenticate => isPlatformSupported && isDeviceSupported;
}
