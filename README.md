# yellow_flowers

Una aplicación móvil desarrollada en Flutter para [descripción breve del propósito de la aplicación]

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

Yellow Flowers es una aplicación móvil desarrollada con Flutter que [descripción detallada del propósito y funcionalidades principales de la aplicación]. El proyecto implementa las mejores prácticas de desarrollo y arquitectura limpia para garantizar un código mantenible y escalable.

## Versión y Requisitos

- Flutter versión: 3.29.1
- Dart SDK: ≥ 3.3.0
- iOS: iOS 12.0 o superior
- Android: Android 5.0 (API 21) o superior

### Mejoras Internas Implementadas

- Implementación de arquitectura limpia (Clean Architecture)
- Gestión de estado con [nombre del state management]
- Inyección de dependencias
- Manejo de rutas con AutoRoute
- Localización implementada
- Tema dinámico (modo claro/oscuro)
- Tests unitarios y de widgets

## Instalación

Sigue estos pasos para clonar el repositorio e instalar las dependencias necesarias:

1. Clona el repositorio:

```bash
git clone https://github.com/tu-usuario/yellow_flowers.git
cd yellow_flowers
```

2. Instala FVM (Flutter Version Management) si no lo tienes instalado:

```bash
dart pub global activate fvm
```

3. Usa FVM para instalar la versión de Flutter especificada en el proyecto:

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

## Solución de Problemas

### Compilación en iOS

Para resolver problemas comunes de compilación en iOS:

1. Asegúrate de tener Xcode actualizado
2. Ejecuta los siguientes comandos:

Install CocoaPods:

```bash
sudo gem install cocoapods
```

```bash
cd /Users/jorgegrullon/Projects/yellow_flowers/ios && pod repo update
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

```bash
open build/app/outputs/flutter-apk/
```

```bash
open build/app/outputs/bundle/release/
```

## iOS IPA/Bundle

- Configurar certificados en Xcode
- Generar archivo IPA:

```bash
fvm flutter build ipa
```

```bash
fvm flutter build ipa --release
```

```bash
open build/ios/ipa/
```

# Recursos

Algunos recursos para ayudarte a comenzar si este es tu primer proyecto Flutter:

- [Lab: Escribe tu primera app Flutter](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Ejemplos útiles de Flutter](https://docs.flutter.dev/cookbook)

Para obtener ayuda sobre el desarrollo con Flutter, consulta la [documentación en línea](https://docs.flutter.dev/), que ofrece tutoriales, ejemplos, guías sobre desarrollo móvil y una referencia completa de la API.

# Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.
