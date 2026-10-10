import 'package:local_auth/error_codes.dart' as auth_error;

import '../models/auth_result.dart';

/// Traduce los códigos de error del sistema operativo a razones de fallo
/// que la interfaz sabe explicar.
///
/// Responsabilidad Única (S): esta clase SOLO traduce códigos; no consulta el
/// hardware ni decide reglas de negocio.
class AuthErrorMapper {
  const AuthErrorMapper();

  AuthFailureReason map(String code) {
    return switch (code) {
      // iOS: si el usuario NEGÓ el permiso de Face ID, llega como NotAvailable.
      auth_error.notAvailable => AuthFailureReason.notAvailable,
      auth_error.notEnrolled => AuthFailureReason.notEnrolled,
      auth_error.passcodeNotSet => AuthFailureReason.passcodeNotSet,
      auth_error.lockedOut => AuthFailureReason.lockedOut,
      auth_error.permanentlyLockedOut => AuthFailureReason.permanentlyLockedOut,
      auth_error.otherOperatingSystem => AuthFailureReason.platformNotSupported,
      _ => AuthFailureReason.unknown,
    };
  }
}
