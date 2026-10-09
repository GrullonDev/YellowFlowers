# AGENTS.md

Instrucciones para agentes que trabajan en este repositorio. Consultar README y configuración para el detalle; este archivo no autoriza publicación ni cambios fuera de la tarea.

## Propósito del proyecto

Amarillas permite crear y compartir dedicatorias florales, guardar momentos y cultivar un jardín diario. Incluye música, estados de ánimo, TTS y notificaciones; no introducir cuentas ni publicidad sin decisión explícita.

## Stack y plataformas

Provider/ChangeNotifier, GetIt, SharedPreferences, just_audio, Firebase Core/Firestore/FCM/Analytics/Crashlytics.

Requisito Dart declarado: `^3.5.1` en `pubspec.yaml`; los rangos de dependencias no prueban la versión resuelta. SDK mediante FVM: `3.47.1` según `.fvmrc`.

Proyectos de plataforma presentes: android, ios, web. Esto no garantiza que todos los plugins funcionen en cada plataforma.

## Estructura del repositorio

`lib/main.dart` inicializa servicios; `lib/app.dart` configura la app. `lib/core/` contiene diseño, resultados e integraciones; `lib/di/injector.dart` registra dependencias. Agregar funcionalidad en su módulo de `lib/features/`; respetar el directorio `Flowers` y sus mayúsculas. `lib/theme/`, `lib/widgets/` y `assets/` reúnen recursos compartidos.

## Preparación y comandos

Requisitos: FVM y SDK de `.fvmrc`; ejecutar `fvm install` sin modificar el pin. Android necesita su toolchain/JDK de Gradle; iOS requiere macOS/Xcode y la gestión de dependencias del proyecto. Integraciones Firebase requieren configuración de desarrollo existente.

| Acción | Comando desde la raíz |
| --- | --- |
| Dependencias | `fvm flutter pub get` |
| Ejecutar | `fvm flutter run -d <dispositivo>` |
| Formato | `fvm dart format lib test` |
| Análisis | `fvm flutter analyze` |
| Pruebas | `fvm flutter test` |
| Build Android de comprobación | `fvm flutter build apk --debug` |



Los comandos fueron contrastados con dependencias, documentación/configuración y suites presentes; no ejecutados al redactar este archivo. Build de distribución requiere firma/configuración adicional; no sustituye despliegue.

## Arquitectura y convenciones

Los `*Bloc` existentes son ChangeNotifier, no flutter_bloc. Mantener la separación data/domain en música y la organización real de cada feature. Usar `Result<T>`/failures y la DI existente; liberar recursos de audio/controladores. Reutilizar `PremiumDesign`, tema y responsive. Mantener identificadores técnicos en inglés y textos de interfaz en español.

Conservar nombres y convenciones del módulo: Dart snake_case para archivos, UpperCamelCase para tipos y lowerCamelCase para miembros. No renombrar APIs/campos persistidos incidentalmente; respetar lints de analysis_options.yaml.

## Experiencia de usuario

Mantener el tono cálido, privado y sin presión. Validar dedicatorias, exportación y permisos de galería/compartir; conservar el jardín al reiniciar. Probar temas claro/oscuro, teclado, escalado de texto y movimiento reducido. Fallos de audio, widgets o notificaciones opcionales no deben bloquear el arranque.

En el flujo afectado, contemplar carga, vacío, éxito y error; dar feedback claro, conservar entradas/datos ante fallos y permitir recuperación. Reutilizar componentes visuales; revisar semántica, foco, contraste y escalado de texto.

## Seguridad y datos

No incluir secretos, credenciales ni datos personales en código, documentación o logs. Usar configuración de entorno existente, validar entradas y manejar fallos de servicios. Respetar autenticación, autorización y permisos. No ejecutar operaciones destructivas sobre datos sin autorización explícita.

La configuración Firebase no autoriza acceso por sí sola. No tratar un identificador local como autenticación al usar FirestoreSyncService. Mantener las dedicatorias y fotos fuera de analítica/logs. No regenerar ni sustituir el keystore de publicación; seguir `docs/RELEASE.md` y configuración de firma existente.

## Pruebas y validación

Validar onboarding → personalización → exportar/compartir, plantado diario sin duplicados, recuperación del jardín, reproducción/pausa y denegación de permisos. `test/widget_test.dart` es el test disponible: comprobar que corresponde a la app antes de interpretar su resultado.

Ejecutar análisis y pruebas relevantes según el cambio; compilar solo plataformas afectadas. Un cambio exclusivamente documental requiere revisar rutas, comandos, alcance y diff, sin pruebas artificiales que repliquen el texto. No afirmar que una prueba pasó si no se ejecutó.

## Flujo de trabajo del agente

Leer también `agents/agents.md`; conservar sus reglas válidas. Sus cifras/pendientes históricos se contrastan con código/configuración vigente. Leer instrucciones aplicables antes de modificar archivos, incluidas las de subdirectorios: su alcance local se respeta. Las instrucciones explícitas del usuario prevalecen.

1. Revisar estado del trabajo y comprender el flujo afectado antes de implementar.
2. Hacer cambios acotados al objetivo; respetar cambios existentes del usuario y evitar refactorizaciones ajenas.
3. Reutilizar componentes y dependencias disponibles; justificar dependencias nuevas.
4. Actualizar documentación si cambia comportamiento o configuración.
5. Ejecutar verificaciones pertinentes y comunicar resultados y pendientes con su motivo.
6. No hacer commits, push o despliegues salvo solicitud o autorización previa del usuario. Esta regla prevalece sobre recomendaciones de commit automático en guías antiguas.

Respetar la guía existente: crear ramas desde `develop` y dirigir PR a `develop`; no escribir directamente en ramas de integración o publicación.

No activar workflows de publicación ni scripts de release como comprobación rutinaria.

## Criterios de finalización

La tarea cumple el comportamiento solicitado, contempla errores/estados relevantes, mantiene convenciones y pasa las verificaciones aplicables que puedan ejecutarse. Comunicar archivos modificados, resultados reales y cualquier validación pendiente con su motivo.

## Limitaciones y aspectos por confirmar

El workflow manual `android-release.yml` usa Flutter 3.35.2 y Java 17, distintos de `.fvmrc`/Store Release. La presencia de FirestoreSyncService no demuestra sincronización autenticada completa. Web tiene scaffold, pero las integraciones móviles requieren comprobación.
