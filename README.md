# 🌸 Yellow Flowers — Premium Emotional Experience

<div align="center">
  <img src="assets/images/logo.png" width="160" height="160" alt="Yellow Flowers Logo">
  
  <h3>Una experiencia diseñada para conectar, emocionar y florecer.</h3>

[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-E74C3C?style=for-the-badge&logo=android)](#)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter)](#)
[![License](https://img.shields.io/badge/License-MIT-F1C40F?style=for-the-badge)](#)

</div>

---

## ✨ El Concepto

**Yellow Flowers** no es simplemente una aplicación; es un **puente emocional digital**. Diseñada con una estética minimalista y de alta gama, permite a los usuarios crear tarjetas virtuales personalizadas con animaciones orgánicas y una atención meticulosa al detalle.

> _"Cada flor es un mensaje, cada pétalo una emoción."_

### 🌟 Funcionalidades Premium

- **🌿 Jardín de Experiencias:** Dashboard inmersivo que centraliza todas las interacciones con elegancia.
- **💌 Mensajes con Alma:** Personalización profunda con algoritmos de color dinámicos.
  - **Temas Florales:** Daisy (Margarita), Rose (Rosa), Sunflower (Girasol).
  - **Moods Dinámicos:** Joy (Alegría), Calm (Calma), Passion (Pasión).
- **📸 Exportación Ultra-HD:** Generación de imágenes (1080×1920) optimizadas para Instagram y WhatsApp Stories, incluyendo códigos QR dinámicos.
- **🎙️ Frase del Día (TTS):** Inspiración diaria narrada con síntesis de voz natural de alta fidelidad.
- **✨ Onboarding de Autor:** Bienvenida personalizada con ilustraciones exclusivas y captura de identidad.

---

## 🎨 Filosofía de Diseño

El proyecto sigue principios de **Diseño Emocional** y **Micro-interacciones**:

- **Animaciones Orgánicas:** Uso de `CustomPainter` y Lottie para simular el florecimiento y movimiento de pétalos.
- **Paletas Curadas:** Colores basados en la psicología del color para cada "Mood".
- **UX Fluida:** Transiciones suaves que mantienen al usuario en un estado de calma.

---

## 🛠️ Stack Tecnológico

Arquitectura robusta diseñada para la evolución constante:

| Tecnología        | Propósito                                            |
| :---------------- | :--------------------------------------------------- |
| **Flutter 3.24+** | SDK Multiplataforma                                  |
| **Provider**      | Gestión de Estado Reactiva                           |
| **GetIt**         | Inyección de Dependencias (Service Locator)          |
| **Just Audio**    | Motor de Experiencia Sonora                          |
| **Firebase**      | Capa de Persistencia y Sync (Core & Cloud Firestore) |
| **Lottie**        | Animaciones Vectoriales Complejas                    |

---

## 🏗️ Arquitectura del Proyecto

Implementamos una transición hacia **Clean Architecture** para garantizar testabilidad y desacoplamiento:

```bash
lib/
├── 📂 core/           # Elementos transversales (Networking, Errors, Theme)
├── 📂 di/             # Configuración de Inyección de Dependencias
├── 📂 features/       # Módulos Funcionales (Dominio de negocio)
│   └── 📂 <feature>/
│       ├── 📂 data/        # Repositorios y fuentes de datos (Remote/Local)
│       ├── 📂 domain/      # Entidades y Casos de Uso (Lógica pura)
│       └── 📂 presentation/ # UI Widgets y BLoC/Providers
└── 📍 main.dart       # Punto de entrada de la aplicación
```

---

## 🚀 Guía de Instalación Rápida

### Requisitos Previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado.
- [CocoadPods](https://cocoapods.org/) para el desarrollo en iOS.

### Configuración del Entorno

```bash
# 1. Clonar el repositorio
git clone https://github.com/GrullonDev/YellowFlowers.git
cd YellowFlowers

# 2. Instalar dependencias
flutter pub get

# 3. Preparar iOS (Solo macOS)
cd ios && pod install && cd ..
```

### Ejecutar Desarrollo

```bash
flutter run
```

---

## 📦 Despliegue y Compilación

### Android (APK / Bundle)

```bash
# Para pruebas locales
flutter build apk --release

# Para publicación en Play Store
flutter build appbundle --release
```

### iOS (IPA)

```bash
# Preparar para App Store Connect
flutter build ipa --release
```

---

## 🤝 Contribuciones

¡Las contribuciones son lo que hacen a la comunidad de código abierto un lugar increíble!

1. Haz un **Fork** del proyecto.
2. Crea tu **Feature Branch** (`git checkout -b feature/AmazingFeature`).
3. Haz **Commit** de tus cambios (`git commit -m 'Add: Amazing Feature'`).
4. **Push** a la rama (`git push origin feature/AmazingFeature`).
5. Abre un **Pull Request**.

---

## 📄 Licencia

Distribuido bajo la Licencia **MIT**. Vea `LICENSE` para más información.

---

<div align="center">
  <p>Diseñado y desarrollado con ❤️ por <b>GrullonDev</b></p>
  <a href="https://github.com/GrullonDev">
    <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" alt="GitHub">
  </a>
</div>
