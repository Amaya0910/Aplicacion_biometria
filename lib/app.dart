import 'package:flutter/material.dart';

import 'controllers/biometric_controller.dart';
import 'screens/home_screen.dart';
import 'services/biometric_service.dart';

/// Widget raíz: configura el tema y la primera pantalla.
class BiometriaApp extends StatelessWidget {
  const BiometriaApp({super.key, required this.service});

  /// Servicio ya construido en `main.dart`: la app no sabe cómo se crea.
  final BiometricService service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometría Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0B1F4D),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF0B1F4D),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      // La pantalla recibe una fábrica de controladores: no crea el servicio.
      home: HomeScreen(controllerFactory: () => BiometricController(service)),
    );
  }
}
