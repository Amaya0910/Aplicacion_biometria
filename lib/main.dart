import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'app.dart';
import 'services/biometric_service.dart';
import 'services/local_auth_platform.dart';

/// Punto de entrada de la aplicación.
///
/// `main` solo hace dos cosas:
///   1. Construye el servicio con la plataforma REAL (`local_auth`).
///   2. Arranca la interfaz.
/// Así ninguna pantalla sabe *cómo* se crean sus dependencias (principio de
/// Inversión de Dependencias, la "D" de SOLID).
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final platform = LocalAuthPlatform(LocalAuthentication());
  final service = BiometricService(platform);

  runApp(BiometriaApp(service: service));
}
