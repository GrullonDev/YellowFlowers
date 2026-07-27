import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Firebase Analytics for the app's core funnel events.
///
/// Fase 1 (ver YellowFlowers_Analisis_Dinamismo_Social.docx, sección 3.1 y
/// 4.D): antes de esta clase la app no tenía ninguna forma de saber qué
/// pantallas se usan, ni si una función realmente engancha. Este servicio
/// centraliza los 6 eventos núcleo definidos en el roadmap:
/// app_open, flower_created, message_shared, music_played, mood_selected,
/// onboarding_completed.
///
/// Cada llamada es "fire and forget" y nunca debe bloquear ni romper el
/// flujo de la UI: cualquier error de red o de Analytics se traga en
/// silencio, igual que el resto de servicios opcionales de la app
/// (NotificationService, TtsService).
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get navigatorObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> _log(String name, [Map<String, Object?>? params]) async {
    try {
      await _analytics.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('AnalyticsService: failed to log "$name": $e');
    }
  }

  /// App fue abierta y terminó de inicializar (main.dart, tras
  /// initDependencies + ensureSignedIn).
  Future<void> logAppOpen() => _log('app_open');

  /// El onboarding narrativo (nombre + intro) fue completado.
  Future<void> logOnboardingCompleted() => _log('onboarding_completed');

  /// El usuario cambió su estado de ánimo global (MoodController.setMood
  /// o el check-in diario de WellnessController).
  Future<void> logMoodSelected(String mood) =>
      _log('mood_selected', {'mood': mood});

  /// Se generó/exportó una tarjeta de flor personalizada.
  Future<void> logFlowerCreated({required String theme, required String mood}) =>
      _log('flower_created', {'theme': theme, 'mood': mood});

  /// El usuario compartió contenido fuera de la app (imagen exportada,
  /// mensaje especial, recuerdo de la galería, etc.).
  Future<void> logMessageShared(String source) =>
      _log('message_shared', {'source': source});

  /// Se reprodujo una canción.
  Future<void> logMusicPlayed({required String songId, required String mood}) =>
      _log('music_played', {'song_id': songId, 'mood': mood});

  /// Evento genérico para cualquier interacción que valga la pena medir
  /// pero que no encaje en los 6 eventos núcleo de arriba.
  Future<void> logCustom(String name, [Map<String, Object?>? params]) =>
      _log(name, params);
}
