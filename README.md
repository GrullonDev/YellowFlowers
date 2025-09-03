# Yellow Flowers

Una app Flutter para crear y personalizar tarjetas de flores virtuales con animaciones sutiles y opciones de compartir/guardar listas para Instagram Stories.

## Tabla de Contenido

- [Descripción](#descripción)
- [Versión y Requisitos](#versión-y-requisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Solución de Problemas](#solución-de-problemas)
- [Contribuir](#contribuir)
- [Recursos](#recursos)
- [Licencia y Administración](#licencia-y-administración)

## Descripción

Yellow Flowers permite generar mensajes bonitos con un fondo animado, flores elegantes y microinteracciones. Puedes personalizar el tema de flores, el estado de ánimo del gradiente y el estilo del nombre. La app exporta una tarjeta en formato 1080×1920 con un código QR configurable para compartir en redes.

## Versión y Requisitos

- Dart SDK: >= 3.5.1 (según `environment.sdk` del proyecto)
- Flutter: compatible con Dart 3.5 (por ejemplo, Flutter 3.24+)
- iOS: 12.0+
- Android: 5.0 (API 21)+

### Funcionalidades clave

- Onboarding cálido con ilustración floral y entrada de nombre estilizada
- Personalización:
	- Tema de flores: Daisy, Rose, Sunflower
	- Ánimo del gradiente de fondo: Joy, Calm, Passion
	- Nombre en cursiva elegante (opcional)
- Pantalla de mensaje animada:
	- Gradiente dinámico, pétalos cayendo, brillos suaves y flores elegantes
	- Transición sutil del mensaje y microinteracciones (bloom al compartir)
- Compartir/Guardar como imagen:
	- Exportación a 1080×1920 (formato Instagram Story)
	- Código QR configurable hacia tu app/sitio
	- Compartir como archivo (share_plus) y guardar en documentos de la app

### Stack técnico

- Flutter + Dart 3.5+
- State management: Provider
- Inyección de dependencias: get_it
- Pintado personalizado (CustomPainter) para flores y efectos
- Paquetes clave: share_plus, pretty_qr_code, google_fonts, path_provider
	- Opcional: just_audio (base presente en el repo para música ambiental)

## Instalación

Sigue estos pasos para clonar el repositorio e instalar las dependencias necesarias:

1. Clona el repositorio:

```bash
git clone https://github.com/GrullonDev/YellowFlowers.git

### Versionado automático de APK (Android)

Se configuró `android/app/build.gradle` para calcular `versionCode` automáticamente al compilar:

Prioridad del `versionCode`:
- Propiedad de Gradle: `-PversionCode=123`
- Variables de entorno CI: `BUILD_NUMBER`, `GITHUB_RUN_NUMBER` o `CI_PIPELINE_IID`
- Cantidad de commits: `git rev-list --count HEAD`
- Marca de tiempo: `yyyyMMddHH`

El `versionName` se mantiene con el valor de `pubspec.yaml` y se concatena `+versionCode` para trazabilidad.

Comandos útiles:

- Mostrar versión resuelta:
	- `./gradlew :app:printVersion`
- Construir APK release con versión automática:
	- `flutter build apk --release`
- Forzar un `versionCode` desde CI/local:
	- `./gradlew :app:assembleRelease -PversionCode=42`

El nombre del APK incluye versión: `yellowflowers-release-v<name>(<code>).apk`, útil para subir a Firebase App Distribution.
cd YellowFlowers
```

2. Instala FVM (Flutter Version Management) si no lo tienes instalado:

```bash
dart pub global activate fvm
```

3. Usa FVM para instalar y usar la versión de Flutter deseada (opcional):

```bash
fvm install
fvm use
```

4. Instala las dependencias del proyecto:

```bash
flutter pub get
```

## Uso

Para ejecutar la aplicación, usa el siguiente comando:

```bash
flutter run
```

Flujo básico:
- Ingresa el nombre de la persona (opcionalmente activa el estilo cursivo)
- Elige el tema de flor y el estado de ánimo del fondo
- En la pantalla del mensaje, usa los íconos de compartir o de descarga

Configurar el enlace del QR:
- Edita `lib/features/Flowers/pages/flower_screen.dart`
- Busca `const qrUrl = 'https://jorgegrullondev.com/';` y cambia al URL final (Play Store/App Store/Deep Link)

## Solución de Problemas

### Compilación en iOS (macOS)

Para resolver problemas comunes de compilación en iOS:

1. Asegúrate de tener Xcode actualizado
2. Ejecuta los siguientes comandos:

Install CocoaPods:

```bash
sudo gem install cocoapods
```

```bash
cd ios && pod repo update
```

```bash
rm -f Podfile.lock
```

```bash
pod deintegrate && pod cache clean --all
```

```bash
cd .. && fvm flutter clean
```

```bash
fvm flutter pub get
```

```bash
cd ios && pod install --repo-update && cd ..
```

```bash
fvm flutter run
```

Setup iOS project:

```bash
cd ios
pod install
cd ..
```

# Contribuir

Si deseas contribuir a este proyecto, sigue estos pasos:

- Haz un fork del repositorio.
- Crea una nueva rama:

```bash
git checkout -b feature/nueva-funcionalidad
```

- Realiza tus cambios y haz commit:

```bash
git commit -m "Añadir nueva funcionalidad"
```

- Sube tus cambios a tu repositorio fork:

```bash
git push origin feature/nueva-funcionalidad
```

- Abre un Pull Request en GitHub.

# Generación de Builds

## Android APK/Bundle

Para generar un APK de debug:

```bash
fvm flutter build apk --debug
```

```bash
fvm flutter build apk --release
```

```bash
fvm flutter build appbundle --release
```

En Windows: explora la carpeta `build\app\outputs\flutter-apk\` en el Explorador.

## iOS IPA/Bundle

- Configurar certificados en Xcode
- Generar archivo IPA:

```bash
fvm flutter build ipa
```

```bash
fvm flutter build ipa --release
```

En macOS: abre `build/ios/ipa/` desde Finder.

# Recursos

Algunos recursos para ayudarte a comenzar si este es tu primer proyecto Flutter:

- [Lab: Escribe tu primera app Flutter](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Ejemplos útiles de Flutter](https://docs.flutter.dev/cookbook)

Para obtener ayuda sobre el desarrollo con Flutter, consulta la [documentación en línea](https://docs.flutter.dev/), que ofrece tutoriales, ejemplos, guías sobre desarrollo móvil y una referencia completa de la API.

# Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.
