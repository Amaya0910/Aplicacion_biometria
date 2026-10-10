/// Resultado de un intento de autenticación.
///
/// Usamos una clase `sealed` (Dart 3): el compilador nos obliga a manejar
/// TODOS los casos posibles en un `switch`, así no se nos olvida el caso en
/// que el usuario niega o cancela.
sealed class AuthResult {
  const AuthResult();
}

/// El usuario se autenticó correctamente.
class AuthSuccess extends AuthResult {
  const AuthSuccess();
}

/// La autenticación no se completó; [reason] explica por qué.
class AuthFailure extends AuthResult {
  const AuthFailure(this.reason, {this.technicalDetail});

  final AuthFailureReason reason;

  /// Detalle técnico opcional (código del sistema), útil para depurar.
  final String? technicalDetail;
}

/// Todas las razones de fallo que la interfaz sabe explicar al usuario.
enum AuthFailureReason {
  /// El usuario tocó "Cancelar" o cerró el diálogo.
  cancelled(
    'Autenticación cancelada',
    'Cancelaste la verificación. Puedes intentarlo de nuevo cuando quieras.',
  ),

  /// El hardware no está disponible o (en iOS) el usuario NEGÓ el permiso de Face ID.
  notAvailable(
    'Biometría no disponible',
    'El sensor no está disponible o negaste el permiso de Face ID. '
        'En iOS ve a Ajustes > aplicacion_biometria > Face ID y actívalo.',
  ),

  /// Hay sensor pero el usuario no registró huellas/rostro.
  notEnrolled(
    'No hay biometría registrada',
    'Registra una huella o tu rostro en los ajustes de seguridad del teléfono.',
  ),

  /// El teléfono no tiene PIN, patrón ni contraseña configurados.
  passcodeNotSet(
    'Sin bloqueo de pantalla',
    'Configura un PIN, patrón o contraseña en el dispositivo para usar biometría.',
  ),

  /// Demasiados intentos fallidos: bloqueo temporal (~30 s en Android).
  lockedOut(
    'Bloqueo temporal',
    'Demasiados intentos fallidos. Espera unos segundos e inténtalo de nuevo.',
  ),

  /// Bloqueo permanente: hay que desbloquear el teléfono con PIN/patrón.
  permanentlyLockedOut(
    'Biometría bloqueada',
    'Desbloquea el teléfono con tu PIN o patrón para reactivar la biometría.',
  ),

  /// Plataforma sin soporte (Web, Linux).
  platformNotSupported(
    'Plataforma no soportada',
    'La biometría nativa no está disponible aquí. En la Web se usaría WebAuthn.',
  ),

  /// Cualquier otro error inesperado.
  unknown(
    'Error inesperado',
    'Ocurrió un error al verificar tu identidad. Inténtalo de nuevo.',
  );

  const AuthFailureReason(this.title, this.userMessage);

  /// Título corto para la interfaz.
  final String title;

  /// Mensaje amigable que le dice al usuario qué hacer.
  final String userMessage;
}
