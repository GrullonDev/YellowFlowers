# 🌸 Yellow Flowers — Premium Emotional Experience

<div align="center">
  <img src="assets/images/app_logo.png" width="128" height="128" alt="Yellow Flowers Logo">
  
  **Una experiencia diseñada para conectar, emocionar y florecer.**
  
  [![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-brightgreen.svg)](#)
  [![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B.svg?logo=flutter)](#)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
</div>

---

## ✨ El Concepto
**Yellow Flowers** no es solo una app; es un puente emocional. Permite a los usuarios crear tarjetas virtuales personalizadas con una estética de alta gama, animaciones fluidas y un diseño orientado al detalle. Perfecta para momentos especiales, compartiendo mensajes con elegancia y sutilidad.

### 🌟 Funcionalidades Premium
- **Jardín de Experiencias:** Un dashboard intuitivo y elegante que agrupa todas las funcionalidades.
- **Mensajes con Alma:** Personalización profunda de tarjetas:
  - **Temas Florales:** Daisy (Margarita), Rose (Rosa), Sunflower (Girasol).
  - **Moods Dinámicos:** Joy (Alegría), Calm (Calma), Passion (Pasión) con gradientes calculados.
- **Exportación 4K Ready:** Generación de imágenes en formato **1080×1920**, listas para Instagram Stories, con códigos QR inteligentes incorporados.
- **Frase del Día (TTS):** Escucha mensajes inspiradores con una síntesis de voz natural y suave.
- **Onboarding de Autor:** Una bienvenida cálida con ilustraciones personalizadas y captura de identidad.

---

## 📱 Plataformas Soportadas
Esta aplicación ha sido optimizada **exclusivamente** para dispositivos móviles:

*   **iOS:** 12.0 o superior.
*   **Android:** API 21 (Android 5.0) o superior.

---

## 🛠️ Stack Tecnológico
Arquitectura moderna pensada en la escalabilidad y el rendimiento:

*   **Framework:** [Flutter](https://flutter.dev) (Dart 3.5+).
*   **Gestión de Estado:** `Provider`.
*   **Inyección de Dependencias:** `GetIt`.
*   **UI/UX:** Custom Painters para animaciones de partículas (pétalos) y efectos visuales.
*   **Persistencia:** Servicios de personalización inteligentes.

---

## 🚀 Guía de Inicio

### Requisitos Previos
1. Tener instalado [Flutter](https://flutter.dev/docs/get-started/install).
2. (Opcional) [FVM](https://fvm.app/) para gestión de versiones.
3. Cocoapods para iOS (`sudo gem install cocoapods`).

### Instalación
```bash
# 1. Clonar el repositorio
git clone https://github.com/GrullonDev/YellowFlowers.git
cd YellowFlowers

# 2. Configurar Flutter (si usas FVM)
fvm install
fvm use

# 3. Obtener dependencias
flutter pub get

# 4. Configurar iOS (solo en macOS)
cd ios
pod install
cd ..
```

### Ejecución
```bash
# Ejecutar en el dispositivo conectado
flutter run
```

---

## 📦 Generación de Builds

### Android (APK & App Bundle)
```bash
# Generar APK de Lanzamiento
flutter build apk --release

# Generar Bundle para la Play Store
flutter build appbundle --release
```
> [!TIP]
> Los archivos resultantes se encuentran en `build/app/outputs/flutter-apk/`.

### iOS (IPA)
```bash
# Generar archivo de distribución
flutter build ipa --release
```
> [!IMPORTANT]
> Requiere configuración previa de perfiles de aprovisionamiento en Xcode.

---

## 🏗️ Arquitectura
El proyecto se encuentra en una transición hacia **Arquitectura Limpia (Clean Architecture)**:

```text
lib/
├── core/            # Modelos base, fallos y casos de uso genéricos.
├── di/              # Inyección de dependencias (Clean Architecture).
├── features/        # Módulos de la app (Music, Flowers, Personalization).
│   ├── <feature>/
│   │   ├── data/    # Implementación de repositorios y fuentes de datos.
│   │   ├── domain/  # Entidades y contratos (Lógica de Negocio).
│   │   └── bloc/    # Presentation logic (Capa de Vista).
└── main.dart        # Punto de entrada.
```

---

## 🔐 Firma de Aplicación y SHA1
Si Play Console muestra un error de huella digital (SHA1) distinta a la esperada:

1. Verifica qué SHA1 espera Play Console.
2. Obtén el SHA1 de tu bundle actual:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
   ```
3. Genera un keystore de subida persistente:
   ```bash
   keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
4. Configura `android/key.properties` (no incluir en Git):
   ```properties
   storePassword=TU_PASSWORD
   keyPassword=TU_PASSWORD
   keyAlias=upload
   storeFile=../app/upload-keystore.jks
   ```
5. Mueve `upload-keystore.jks` a `android/app/` y compila con `fvm flutter build appbundle --release`.

> [!NOTE]
> Para inspeccionar la firma de un AAB: `unzip -p build/app/outputs/bundle/release/app-release.aab META-INF/CERT.RSA | keytool -printcert -v -rfc | grep SHA1`

---

## 📄 Licencia
Este proyecto está bajo la licencia **MIT**. Siéntete libre de usarlo para inspirarte o extenderlo.

---
<div align="center">
  Diseñado con ❤️ por <b>GrullonDev</b>
</div>
