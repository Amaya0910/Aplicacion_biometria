import '../models/biometric_kind.dart';

/// Contrato de acceso a la plataforma de biometría (el "hardware").
///
/// Separar el acceso a la plataforma del servicio nos permite:
/// - Cambiar `local_auth` por otro plugin sin tocar el servicio.
/// - Crear un "falso" en las pruebas unitarias sin necesitar un teléfono.
abstract interface class BiometricPlatform {
  /// `false` en plataformas donde el plugin no existe (Web, Linux).
  bool get isPlatformSupported;

  Future<bool> isDeviceSupported();

  Future<bool> canCheckBiometrics();

  Future<List<BiometricKind>> getEnrolledBiometrics();

  /// Devuelve `true` si el usuario se autenticó y `false` si canceló.
  /// Lanza `PlatformException` ante errores del sistema operativo.
  Future<bool> authenticate({
    required String reason,
    required bool biometricOnly,
  });

  Future<void> stopAuthentication();
}
