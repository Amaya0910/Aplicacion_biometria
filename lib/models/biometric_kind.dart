/// Tipos de biometría que puede reportar un dispositivo.
///
/// Es nuestra propia enumeración de dominio: NO usamos directamente
/// `BiometricType` de `local_auth` para que el dominio no dependa de un
/// paquete externo.
enum BiometricKind {
  /// Lector de huella dactilar.
  fingerprint('Huella dactilar'),

  /// Reconocimiento facial (Face ID en iOS, desbloqueo facial en Android).
  face('Reconocimiento facial'),

  /// Lector de iris (algunos Samsung).
  iris('Iris'),

  /// Android: biometría de clase 3 (fuerte), apta para pagos y criptografía.
  strong('Biometría fuerte (Clase 3)'),

  /// Android: biometría de clase 2 (débil), solo para desbloqueos simples.
  weak('Biometría débil (Clase 2)');

  const BiometricKind(this.label);

  /// Texto legible para mostrar en pantalla.
  final String label;
}
