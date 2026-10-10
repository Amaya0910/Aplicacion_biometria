# 🔐 Biometría con Flutter

App de ejemplo para **Programación Móvil (SS603)** que autentica al usuario con **huella dactilar o Face ID** usando el paquete [`local_auth`](https://pub.dev/packages/local_auth).

## 1. ¿Qué es la biometría?

Es verificar la identidad de una persona con algo que es (huella, rostro, iris) en lugar de algo que sabe (una contraseña).

**Cómo funciona:**

```
Sensor → Zona segura del chip (Secure Enclave / TEE) → "sí / no" → Sistema operativo → App
```

La app **nunca recibe la huella ni la imagen del rostro**: el sistema solo le responde verdadero o falso. Los datos biométricos no salen del chip seguro.

**Casos de uso:** apps bancarias, gestores de contraseñas, confirmar pagos, bloquear chats o notas privadas.

## 2. Paquete elegido: `local_auth`

Paquete oficial del equipo de Flutter.

| Android | iOS | macOS | Windows | Web | Linux |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |

Métodos principales: `isDeviceSupported()`, `canCheckBiometrics`, `getAvailableBiometrics()` y `authenticate()`.

```yaml
# pubspec.yaml
dependencies:
  local_auth: ^2.3.0   # se fija la versión 2.x: la 3.x cambió la API
```

## 3. Permisos por plataforma

### 🤖 Android

**`android/app/src/main/AndroidManifest.xml`**, antes de `<application>`:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

- Es un permiso **normal**: se concede al instalar y **no muestra ningún diálogo**.
- No hay permiso "en ejecución": el consentimiento es el propio `BiometricPrompt`, que el usuario puede cancelar.

**`MainActivity.kt`** debe usar `FlutterFragmentActivity` (si no, falla con `no_fragment_activity`):

```kotlin
class MainActivity : FlutterFragmentActivity()
```

**`build.gradle(.kts)`:** `minSdk = 23`.

### 🍎 iOS

**`ios/Runner/Info.plist`**:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Usamos Face ID para proteger el acceso a tu bóveda segura.</string>
```

- Face ID **sí** requiere esta clave; sin ella la app se cierra. Touch ID no la necesita.
- Si el usuario **niega** el permiso, `local_auth` devuelve el error `NotAvailable` y la app le explica cómo activarlo en *Ajustes → la app → Face ID*.
- **Capabilities:** no se necesita ninguna en Xcode.

### 🌐 Web

- `local_auth` **no soporta Web**: la app lo detecta con `kIsWeb` y muestra una explicación en lugar de fallar.
- Alternativa del navegador: **WebAuthn / Passkeys** (`navigator.credentials.create()` y `.get()`). El navegador pide la huella o el rostro al sistema operativo y el sitio solo recibe una firma criptográfica.
- Limitaciones: exige **HTTPS** (o `localhost`) y un **servidor** que registre y valide las credenciales.

## 4. Qué hace la app

- Muestra qué soporta el dispositivo (bloqueo seguro, sensor, biometrías registradas).
- Abre una "bóveda segura" solo tras autenticarse.
- Interruptor **solo biometría / con PIN de respaldo**.
- Maneja cada fallo con un mensaje claro: cancelación, permiso negado, sin huellas registradas, sin bloqueo de pantalla, bloqueo por intentos y plataforma no soportada.

```
lib/
├── models/        # AuthResult, BiometricKind, BiometricStatus
├── services/      # BiometricService, AuthErrorMapper, LocalAuthPlatform
├── controllers/   # BiometricController (estado de la pantalla)
├── screens/       # HomeScreen, VaultScreen
└── widgets/       # tarjetas y banner de resultado
```

```bash
flutter pub get
flutter test    # 12 pruebas unitarias
flutter run     # en un Android con huella registrada
```

## 5. Conclusiones

- La biometría mejora la **seguridad** y la **experiencia de usuario** a la vez.
- Flutter la integra con muy poco código gracias a `local_auth`; cada plataforma solo necesita su configuración.
- Lo más importante no es el caso feliz, sino **manejar todos los errores**.

## 6. Buenas prácticas

- Ofrecer siempre una alternativa (PIN o patrón) y manejar el "no" del usuario.
- Explicar **por qué** se pide el permiso (el texto del `Info.plist`).
- No usar la biometría como único factor en operaciones críticas sin validación en un servidor.
- Separar la lógica del plugin en una interfaz para poder probarla sin teléfono.

## 7. Dificultades

- Cambiar `FlutterActivity` por `FlutterFragmentActivity`.
- La versión 3.x de `local_auth` cambió la API, por lo que se fijó la 2.x.
- Activar el *Modo de desarrollador* de Windows para compilar plugins.
- Registrar una huella en el emulador / teléfono para poder probar.

## 8. Repositorio y créditos

🔗 **Repositorio:** [https://github.com/USUARIO/REPOSITORIO](https://github.com/USUARIO/REPOSITORIO)

| Integrante | Correo | Sección del video |
|---|---|---|
| Tay [Apellido] | [correo] | [sección] |
| Brayan [Apellido] | [correo] | [sección] |

**Curso:** Programación Móvil (SS603) · Universidad Popular del Cesar
**Paquetes:** [`local_auth`](https://pub.dev/packages/local_auth)