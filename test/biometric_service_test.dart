import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplicacion_biometria/models/auth_result.dart';
import 'package:aplicacion_biometria/models/biometric_kind.dart';
import 'package:aplicacion_biometria/services/biometric_platform.dart';
import 'package:aplicacion_biometria/services/biometric_service.dart';

/// Plataforma FALSA: simula el hardware sin necesitar un teléfono.
/// Esto es posible gracias a la Inversión de Dependencias: el servicio
/// depende de la interfaz `BiometricPlatform`, no de `local_auth`.
class FakeBiometricPlatform implements BiometricPlatform {
  FakeBiometricPlatform({
    this.platformSupported = true,
    this.deviceSupported = true,
    this.hasHardware = true,
    this.enrolled = const [BiometricKind.fingerprint],
    this.authResponse = true,
    this.errorCode,
  });

  final bool platformSupported;
  final bool deviceSupported;
  final bool hasHardware;
  final List<BiometricKind> enrolled;
  final bool authResponse;

  /// Si no es null, `authenticate` lanza una PlatformException con este código.
  final String? errorCode;

  int authenticateCalls = 0;

  @override
  bool get isPlatformSupported => platformSupported;

  @override
  Future<bool> isDeviceSupported() async => deviceSupported;

  @override
  Future<bool> canCheckBiometrics() async => hasHardware;

  @override
  Future<List<BiometricKind>> getEnrolledBiometrics() async => enrolled;

  @override
  Future<bool> authenticate({required String reason, required bool biometricOnly}) async {
    authenticateCalls++;
    if (errorCode != null) throw PlatformException(code: errorCode!);
    return authResponse;
  }

  @override
  Future<void> stopAuthentication() async {}
}

BiometricService _buildService(FakeBiometricPlatform source) =>
    BiometricService(source);

AuthFailureReason? _reasonOf(AuthResult result) =>
    result is AuthFailure ? result.reason : null;

void main() {
  group('BiometricService.authenticate', () {
    test('devuelve éxito cuando el usuario se autentica', () async {
      final result = await _buildService(FakeBiometricPlatform()).authenticate();
      expect(result, isA<AuthSuccess>());
    });

    test('devuelve "cancelled" cuando el usuario cierra el diálogo', () async {
      final result = await _buildService(FakeBiometricPlatform(authResponse: false)).authenticate();
      expect(_reasonOf(result), AuthFailureReason.cancelled);
    });

    test('no abre el diálogo si no hay biometría registrada', () async {
      final source = FakeBiometricPlatform(enrolled: const []);
      final result = await _buildService(source).authenticate();

      expect(_reasonOf(result), AuthFailureReason.notEnrolled);
      expect(source.authenticateCalls, 0);
    });

    test('permite PIN como respaldo aunque no haya biometría registrada', () async {
      final source = FakeBiometricPlatform(enrolled: const []);
      final result = await _buildService(source).authenticate(biometricOnly: false);

      expect(result, isA<AuthSuccess>());
    });

    test('informa plataforma no soportada (Web / Linux)', () async {
      final result = await _buildService(FakeBiometricPlatform(platformSupported: false)).authenticate();
      expect(_reasonOf(result), AuthFailureReason.platformNotSupported);
    });

    test('informa que falta bloqueo de pantalla', () async {
      final result = await _buildService(FakeBiometricPlatform(deviceSupported: false)).authenticate();
      expect(_reasonOf(result), AuthFailureReason.passcodeNotSet);
    });
  });

  group('BiometricService traduce errores del sistema', () {
    final cases = {
      'NotAvailable': AuthFailureReason.notAvailable, // p. ej. permiso de Face ID negado
      'NotEnrolled': AuthFailureReason.notEnrolled,
      'LockedOut': AuthFailureReason.lockedOut,
      'PermanentlyLockedOut': AuthFailureReason.permanentlyLockedOut,
      'PasscodeNotSet': AuthFailureReason.passcodeNotSet,
      'CodigoDesconocido': AuthFailureReason.unknown,
    };

    cases.forEach((code, expected) {
      test('$code → ${expected.name}', () async {
        final result = await _buildService(FakeBiometricPlatform(errorCode: code)).authenticate();
        expect(_reasonOf(result), expected);
      });
    });
  });
}
