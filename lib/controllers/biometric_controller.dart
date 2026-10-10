import 'package:flutter/foundation.dart';

import '../models/auth_result.dart';
import '../models/biometric_status.dart';
import '../services/biometric_service.dart';

/// Controlador de la pantalla (patrón "ViewModel").
///
/// - Guarda el ESTADO que la interfaz dibuja.
/// - Llama al servicio; nunca habla con `local_auth` directamente.
/// - Avisa a la interfaz con `notifyListeners()` cuando algo cambia.
///
/// Usamos `ChangeNotifier` (incluido en Flutter) para no añadir paquetes
/// extra de gestión de estado y mantener el ejemplo fácil de explicar.
class BiometricController extends ChangeNotifier {
  BiometricController(this._service);

  final BiometricService _service;

  // ---------------------------------------------------------------- Estado --

  BiometricStatus? _status;
  BiometricStatus? get status => _status;

  bool _isLoadingStatus = false;
  bool get isLoadingStatus => _isLoadingStatus;

  bool _isAuthenticating = false;
  bool get isAuthenticating => _isAuthenticating;

  AuthResult? _lastResult;
  AuthResult? get lastResult => _lastResult;

  /// true = solo huella/rostro; false = también se acepta PIN/patrón.
  bool _biometricOnly = true;
  bool get biometricOnly => _biometricOnly;

  bool _disposed = false;

  // -------------------------------------------------------------- Acciones --

  /// Consulta las capacidades del dispositivo.
  Future<void> loadStatus() async {
    _isLoadingStatus = true;
    _notify();

    _status = await _service.getStatus();

    _isLoadingStatus = false;
    _notify();
  }

  void setBiometricOnly(bool value) {
    _biometricOnly = value;
    _lastResult = null;
    _notify();
  }

  /// Lanza el diálogo nativo y devuelve el resultado para que la pantalla
  /// decida si navega (éxito) o muestra el error (fallo / permiso negado).
  Future<AuthResult> authenticate() async {
    if (_isAuthenticating) {
      // Evita abrir dos diálogos si el usuario toca el botón dos veces.
      return const AuthFailure(AuthFailureReason.cancelled);
    }

    _isAuthenticating = true;
    _lastResult = null;
    _notify();

    final result = await _service.authenticate(biometricOnly: _biometricOnly);

    _isAuthenticating = false;
    _lastResult = result;
    _notify();
    return result;
  }

  /// Limpia el último mensaje (p. ej. al volver de la bóveda).
  void clearResult() {
    _lastResult = null;
    _notify();
  }

  // ---------------------------------------------------------------- Ciclo --

  /// Notifica solo si el controlador sigue vivo (evita errores si la
  /// pantalla se cerró mientras se esperaba al sistema operativo).
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_isAuthenticating) _service.cancel();
    super.dispose();
  }
}
