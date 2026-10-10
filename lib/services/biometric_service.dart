import 'package:flutter/services.dart';

import '../models/auth_result.dart';
import '../models/biometric_status.dart';
import 'auth_error_mapper.dart';
import 'biometric_platform.dart';

/// Servicio de biometría: la ÚNICA clase que la app usa para autenticar.
///
/// Reúne tres responsabilidades que antes estaban en capas separadas:
///   1. Consultar qué soporta el dispositivo ([getStatus]).
///   2. Aplicar las reglas antes de abrir el diálogo ([authenticate]).
///   3. Convertir los errores técnicos en resultados claros ([AuthFailure]).
///
/// No conoce `local_auth`: habla con la interfaz [BiometricPlatform], que se
/// inyecta por el constructor (Inversión de Dependencias, la "D" de SOLID).
/// Por eso en las pruebas se le pasa una plataforma falsa, sin teléfono.
class BiometricService {
  const BiometricService(
    this._platform, [
    this._errorMapper = const AuthErrorMapper(),
  ]);

  final BiometricPlatform _platform;
  final AuthErrorMapper _errorMapper;

  /// Texto por defecto que aparece en el diálogo nativo.
  static const defaultReason = 'Confirma tu identidad para abrir la bóveda segura';

  /// Consulta qué soporta el dispositivo y qué biometrías están registradas.
  Future<BiometricStatus> getStatus() async {
    if (!_platform.isPlatformSupported) {
      return const BiometricStatus.unsupportedPlatform();
    }

    try {
      final isDeviceSupported = await _platform.isDeviceSupported();
      final canCheckBiometrics = await _platform.canCheckBiometrics();
      final enrolled = await _platform.getEnrolledBiometrics();

      return BiometricStatus(
        isPlatformSupported: true,
        isDeviceSupported: isDeviceSupported,
        canCheckBiometrics: canCheckBiometrics,
        enrolledBiometrics: List.unmodifiable(enrolled),
      );
    } on PlatformException {
      // Si la consulta falla, asumimos lo más seguro: no hay biometría.
      return const BiometricStatus(
        isPlatformSupported: true,
        isDeviceSupported: false,
        canCheckBiometrics: false,
        enrolledBiometrics: [],
      );
    }
  }

  /// Verifica la identidad del usuario.
  ///
  /// Antes de mostrar el diálogo comprueba que el dispositivo pueda
  /// autenticar, para devolver un error claro en lugar de dejar que el
  /// sistema falle de forma confusa.
  Future<AuthResult> authenticate({
    String reason = defaultReason,
    bool biometricOnly = true,
  }) async {
    final status = await getStatus();

    // 1. Plataforma sin soporte (Web / Linux): ni siquiera lo intentamos.
    if (!status.isPlatformSupported) {
      return const AuthFailure(AuthFailureReason.platformNotSupported);
    }

    // 2. Sin bloqueo de pantalla no hay biometría ni PIN que pedir.
    if (!status.isDeviceSupported) {
      return const AuthFailure(AuthFailureReason.passcodeNotSet);
    }

    // 3. Si exigimos SOLO biometría, debe haber al menos una registrada.
    if (biometricOnly && status.enrolledBiometrics.isEmpty) {
      return status.canCheckBiometrics
          ? const AuthFailure(AuthFailureReason.notEnrolled)
          : const AuthFailure(AuthFailureReason.notAvailable);
    }

    // 4. Todo en orden: mostramos el diálogo del sistema.
    try {
      final didAuthenticate = await _platform.authenticate(
        reason: reason,
        biometricOnly: biometricOnly,
      );

      // `false` sin excepción = el usuario canceló o cerró el diálogo.
      return didAuthenticate
          ? const AuthSuccess()
          : const AuthFailure(AuthFailureReason.cancelled);
    } on PlatformException catch (e) {
      return AuthFailure(
        _errorMapper.map(e.code),
        technicalDetail: '${e.code}: ${e.message}',
      );
    } catch (e) {
      return AuthFailure(AuthFailureReason.unknown, technicalDetail: e.toString());
    }
  }

  /// Cancela una autenticación en curso (si la plataforma lo permite).
  Future<void> cancel() async {
    if (!_platform.isPlatformSupported) return;
    try {
      await _platform.stopAuthentication();
    } on PlatformException {
      // Cancelar es "mejor esfuerzo": si falla, no hay nada más que hacer.
    }
  }
}
