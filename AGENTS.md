# AGENTS.md — Guía rápida para agentes (YellowFlowers / Amarillas)

> Punto de entrada para cualquier agente que trabaje en este repositorio.
> El detalle técnico profundo (capas, animaciones, haptics, firma de Android, deuda técnica
> catalogada) vive en [`agents/agents.md`](agents/agents.md) — en inglés, y es la fuente
> autoritativa cuando este archivo y aquel entren en conflicto en un detalle de implementación.
> Este archivo no lo duplica: lo resume y, cuando hace falta precisión, remite a él.

## Propósito del proyecto

**Amarillas** (nombre público: *Flores Amarillas*, paquete `yellow_flowers`) es una app Flutter
para Android e iOS centrada en bienestar emocional y conexión entre personas. El flujo central:
elegir una flor y un ánimo, escribir (opcionalmente) una dedicatoria, ver una vista previa y
compartirla como imagen (WhatsApp/Instagram). Un segundo núcleo es un "jardín" diario: cada
visita planta o hace crecer una flor, y las rachas se presentan como jardín, nunca como contador.

No hay cuentas, login ni anuncios — es una decisión de producto deliberada (ver "No-goals" en
`agents/agents.md` §1). Analítica, Crashlytics y push ya están activos y son anónimos.

## Stack y plataformas

Verificado en `pubspec.yaml`, `.fvmrc` y `agents/agents.md` §2.1:

- **Flutter 3.47.1**, fijado vía FVM (`.fvmrc`) — usa siempre `fvm flutter ...`, nunca `flutter`
  a secas si fvm está instalado.
- **Dart SDK** `^3.5.1`.
- **Estado/DI**: `provider` 6.x (`ChangeNotifier`) + `get_it` 8.x (`lib/di/injector.dart`).
- **Backend**: Firebase — `firebase_core`, `cloud_firestore` (solo lectura, colección `songs`),
  `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics`. Proyecto `yellowflowers-58d52`.
- **Audio**: `just_audio` + `just_audio_background` (una sola instancia global de `AudioPlayer`),
  solo URLs remotas.
- **Plataformas soportadas**: Android e iOS (bundle id `com.grullondev.amarillas`, URL scheme
  `amarillas`). Hay carpetas `linux/`, `macos/`, `web/` generadas por el tooling de Flutter, pero
  no son plataformas de producto activas — no asumas soporte funcional ahí sin confirmarlo.
- Toolchain completo (versiones exactas de AGP, Gradle, Kotlin, compileSdk/minSdk, NDK, Java):
  `agents/agents.md` §2.1 — no lo retranscribas aquí para evitar que ambos archivos se desincronicen.

## Estructura del repositorio

```
lib/
├── main.dart              # bootstrap: Firebase, Crashlytics, JustAudioBackground, DI, FCM
├── app.dart                # MaterialApp, controllers globales, enrutamiento de cold-start
├── core/                   # diseño, transiciones, Result, TTS, servicios transversales
├── di/injector.dart        # único lugar donde se registran servicios (GetIt)
├── data/                   # servicios Firebase delgados (music_service/)
├── features/<feature>/     # pages/ · widgets/ · bloc|controller/ · models/ · data/ · domain/
├── theme/                  # app_theme.dart, theme_controller.dart
├── utils/                  # constants.dart, base_model.dart
└── widgets/                # widgets compartidos entre features (premium_widgets, share_canvas, …)
test/                        # mismo árbol que lib/ (test/features/<feature>/, test/widgets/)
android/ ios/                # proyectos nativos
fastlane/ scripts/ .github/workflows/  # pipeline de release (ver "Preparación y comandos")
agents/agents.md             # guía técnica profunda (arquitectura, convenciones, deuda técnica)
docs/RELEASE.md              # secrets y pasos de publicación
```

Código nuevo: añade una carpeta bajo `lib/features/<feature>/` siguiendo el patrón
`pages/ widgets/ bloc|controller/`. Un test nuevo va en la ruta espejo bajo `test/`.

## Preparación y comandos

Requisitos: Flutter gestionado con FVM (`.fvmrc` fija `3.47.1`); para iOS, CocoaPods.

```bash
fvm flutter pub get              # instalar dependencias
fvm flutter run -d <device>       # ejecutar
fvm flutter analyze               # análisis estático — debe quedar en cero errores y cero infos
fvm flutter test                  # correr toda la suite
fvm flutter test <ruta_archivo>   # correr un solo archivo de test
fvm flutter build apk --debug     # build Android de depuración
fvm flutter build apk --release   # build Android de release (ver firma más abajo)
fvm flutter build ipa --release   # build iOS de release
```

Versionado: `scripts/bump_version.sh [patch|minor|major|build]` solo sube la versión en
`pubspec.yaml`; `scripts/release_ios.sh [minor|major]` sube versión y compila el `.ipa`. Ambos
usan `fvm` si está instalado.

Firma de Android: `android/app/build.gradle` resuelve credenciales en cascada (env vars → `.env`
en la raíz → `android/key.properties`); si faltan, cae a `signingConfigs.debug` para no bloquear
el trabajo local. Detalle completo y riesgos: `agents/agents.md` §2.1. Plantilla de `.env`:
`.env.example`.

CI (`.github/workflows/`): `android-release.yml` (manual, `workflow_dispatch`, sube a Firebase
App Distribution) y `store-release.yml` (iOS a TestFlight en cada push a `main` que toque
`pubspec.yaml`, o manual para Android/Google Play). Ninguno de los dos ejecuta `flutter analyze`
ni `flutter test` — esas verificaciones son responsabilidad del agente/desarrollador antes de
hacer push. Secrets necesarios: `docs/RELEASE.md`.

**Limitación observada en esta sesión**: en un volumen de red (p. ej. `/Volumes/...` en macOS),
macOS genera archivos AppleDouble (`._*`) que pueden romper `flutter test` (si aparecen bajo
`test/`, el loader de test intenta cargarlos) y `flutter build apk` (Gradle falla al fusionar
recursos). Si ves un crash de la herramienta mencionando codificación UTF-8 o un `._*` como
"not a directory", borra esos archivos (`find . -name "._*" -delete`) y reintenta; no es un
problema del código.

## Arquitectura y convenciones

Resumen — el detalle completo con ejemplos está en `agents/agents.md` §2.2–§4:

- **Una feature solo importa de** `lib/core`, `lib/theme`, `lib/widgets`, `lib/utils` y de sí
  misma. Nunca importes la página/bloc/data de otra feature (los widgets presentacionales
  compartidos, p. ej. `garden/widgets/growing_flower.dart`, son la única excepción tolerada).
- **`lib/core` y `lib/widgets` nunca importan de `lib/features/`**. La flecha de dependencia va
  en un solo sentido.
- **Estado de presentación**: `ChangeNotifier` como `*Controller` (global, registrado en
  `app.dart`) o `*Bloc extends BaseModel` (por ruta, vía `BaseModelScaffold`). `*Bloc` aquí
  significa `ChangeNotifier`, no `flutter_bloc` — ese paquete no es dependencia del proyecto.
- **Servicios e infraestructura** se registran únicamente en `lib/di/injector.dart`
  (`registerLazySingleton`, con `sl.isRegistered<T>()` para no romper hot reload).
- **Errores**: `sealed Result<T>` (`lib/core/result.dart`) en data sources/repositorios; no
  lances excepciones crudas entre capas, y no silencies una sin un `debugPrint` que explique por qué.
- **Diseño**: todo color/espaciado/tipografía sale de `PremiumDesign`
  (`lib/core/design_system.dart`); nunca un color o radio fijo a mano. El modo oscuro es
  obligatorio en toda superficie nueva.
- **Un widget público por archivo**, nombre de archivo = nombre del widget en `snake_case`.
  Divide una pantalla que supere ~400 líneas en `pages/` + `widgets/`.
- **Animaciones**: nunca `setState` dentro de un callback de animación; usa
  `AnimatedBuilder`/`ListenableBuilder` o `CustomPainter`. Presupuesto: 60 fps en Android de gama
  media. Reglas completas (loops, `RepaintBoundary`, partículas): `agents/agents.md` §4.3.
- **Haptics**: solo `HapticFeedback` (nunca `SystemSound`), con el vocabulario fijado en
  `agents/agents.md` §4.4 — siempre acompañado de feedback visual.
- **Navegación**: `Navigator` 1.0 imperativo (no `go_router`, no rutas nombradas). El cold-start
  se resuelve una sola vez en `MyApp._initialPage()` (`app.dart`) vía `LaunchParams`.
- **Convención de ramas y commits** (ya en uso en el historial real del repo): `main` solo por
  releases, `develop` como rama de integración, `feature/*`/`fix/*` corto desde `develop`;
  Conventional Commits en inglés, cuerpo explicando el *por qué*. No inventes una convención
  distinta.

## Experiencia de usuario

Criterios observables en el código existente que cualquier cambio de UI debe mantener:

- **Estados de carga/vacío/error**: una operación remota que falla (compartir, exportar imagen,
  reproducir audio) debe dejar la UI en un estado interactivo de nuevo — nunca un spinner
  permanente — y mostrar feedback visible (p. ej. `SnackBar`) en vez de fallar en silencio.
- **Accesibilidad**: todo control que sea solo ícono o chip necesita `Semantics(button: true,
  label: ...)` o un tooltip; objetivo táctil mínimo 44×44; el texto debe escalar (sin alturas
  fijas en contenedores de texto, sin `TextOverflow.clip` en copy visible al usuario).
- **Responsive**: tamaños derivados de `MediaQuery`/`LayoutBuilder`, nunca un tamaño de
  dispositivo fijo. Hojas inferiores con altura acotada o `DraggableScrollableSheet`.
- **Coherencia visual**: paleta cálida (dorado/crema/lavanda/verde hoja), tipografía serif para
  display, sombras suaves; nada que se sienta como "app de productividad" (sin badges de
  urgencia, sin alertas rojas).
- **Preservación de datos**: antes de romper un flujo en curso (p. ej. interrumpir una
  narración o una exportación), asegúrate de que el estado previo se recupera correctamente.

## Seguridad y datos

- Nunca incluyas secretos, credenciales ni datos personales en código, documentación o logs.
  `.env`, `*.jks`, `*.keystore`, `android/key.properties` y los secretos de CI nunca se commitean
  (`.gitignore` ya los cubre — verifica antes de un `git add -A`).
- Usa la configuración de entorno existente (`.env.example` como plantilla); no inventes un
  mecanismo nuevo de configuración.
- Valida entradas y maneja errores de servicios externos (Firebase, TTS, audio, permisos) con el
  patrón `Result<T>` ya establecido; no asumas que una llamada remota siempre tiene éxito.
- Respeta permisos: se solicitan en el momento de uso, con UI explicativa — nunca al arrancar la
  app (ver `agents/agents.md` §4.2).
- No hay autenticación de usuario en este proyecto (ver "Propósito"); no la introduzcas sin una
  decisión de producto explícita, y no asumas que `FirestoreSyncService` (preparado pero inactivo)
  está en uso.
- No realices operaciones destructivas sobre datos (borrar colecciones de Firestore, revocar
  llaves de firma, etc.) sin autorización explícita de quien te lo pide.

## Testing y validación

- Antes de dar por cerrado un cambio: `fvm flutter analyze` (cero errores, cero infos) y
  `fvm flutter test` (o el archivo específico que corresponda al código tocado).
- La suite de test sigue el árbol de `lib/` (`test/features/<feature>/...`,
  `test/widgets/...`). Si agregas o corriges comportamiento en un bloc/controller o un widget
  reusable, añade un test ahí — no hay una herramienta de cobertura configurada, así que el
  criterio es "¿se puede romper este comportamiento sin que ningún test lo note?".
- `test/widget_test.dart` es la plantilla de contador sin modificar de `flutter create`; **falla
  siempre** y es deuda conocida preexistente (no relacionada con tu cambio) — no la tomes como
  referencia de cómo escribir un test nuevo.
- Flujos críticos de producto a validar manualmente cuando los toques: crear y compartir una
  flor (incluye que la vista previa coincida con lo que se comparte, y que la imagen exportada
  salga en la proporción correcta), narración TTS mientras hay música de fondo (deben convivir
  sin solaparse), y plantar/ver el jardín diario.
- No se puede levantar un emulador/dispositivo real ni verificar sonido/lector de pantalla desde
  un entorno de agente sin GUI — si tu cambio toca audio, TTS o accesibilidad, dilo explícitamente
  como verificación pendiente en vez de asumir que "debería funcionar".

## Flujo de trabajo del agente

- Lee las instrucciones aplicables (este archivo y, si tocas algo que cubre en detalle,
  `agents/agents.md`) antes de modificar archivos.
- Entiende el flujo afectado antes de implementar — explora el código real, no asumas por el
  nombre de un archivo o del README.
- Limita el cambio al objetivo pedido; evita refactors no relacionados con la tarea.
- Respeta el trabajo ya presente en el árbol de trabajo (cambios del usuario, archivos sin
  commitear) — no los descartes sin preguntar.
- Reutiliza componentes y dependencias ya disponibles antes de añadir uno nuevo; si una
  dependencia nueva es necesaria, justifica por qué en la descripción del cambio.
- Actualiza `agents/agents.md` o este archivo si tu cambio altera un comportamiento o
  configuración que ambos documentan — mantenlos coherentes entre sí.
- Ejecuta las verificaciones relevantes (`flutter analyze`, `flutter test` del área tocada) y
  comunica el resultado real, incluyendo fallos preexistentes que no sean tuyos.
- No afirmes que un test pasó si no lo ejecutaste.
- No hagas commits, pushes ni despliegues salvo que te lo pidan explícitamente o ya esté
  autorizado para esta tarea.

## Criterios de finalización

Una tarea está completa cuando:

- Cumple el comportamiento pedido, incluyendo estados de error y casos límite relevantes.
- Mantiene las convenciones de este archivo y de `agents/agents.md` (capas, diseño, animaciones,
  accesibilidad).
- `fvm flutter analyze` queda en cero errores/infos y `fvm flutter test` pasa para el área
  tocada (los fallos preexistentes no relacionados se reportan, no se esconden).
- Se comunica cualquier verificación pendiente (dispositivo real, audio, lector de pantalla,
  secretos de CI) y la razón por la que no se pudo ejecutar desde este entorno.

## Limitaciones y aspectos por confirmar

- La suite de tests es parcial: cubre los módulos tocados recientemente (flujo de creación de
  flor, coordinación de audio TTS/música, `ShareCanvas`), no toda la app.
- Hay deuda técnica catalogada explícitamente en `agents/agents.md` §6 (archivos sin referenciar,
  desalineación de versión de Flutter en `android-release.yml`, convención de archivo violada en
  `share_helper.dart`, migración pendiente a AGP 9) — no construyas sobre esos puntos sin
  resolverlos primero.
- No se puede confirmar desde el código si los secrets de CI (`FIREBASE_*`, `ASC_*`, `MATCH_*`,
  `ANDROID_KEYSTORE_*`, `PLAY_SERVICE_ACCOUNT_JSON`) están realmente configurados en el
  repositorio de GitHub — solo que los workflows los esperan.
- `FirestoreSyncService` está registrado pero inactivo (requiere una capa de autenticación que
  no existe); no asumas que el backup/restore de rachas funciona.
