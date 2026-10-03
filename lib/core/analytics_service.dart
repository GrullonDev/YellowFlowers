import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  Future<void> logEvent(String name, [Map<String, Object>? params]) =>
      _analytics.logEvent(name: name, parameters: params);

  Future<void> logGardenVisit() => logEvent('garden_visit');

  Future<void> logMoodCheckin(String mood) =>
      logEvent('mood_checkin', {'mood': mood});

  Future<void> logFlowerPlanted() => logEvent('flower_planted');

  Future<void> logStreakDay(int day) => logEvent('streak_day', {'day': day});

  Future<void> logMusicPlay(String songId) =>
      logEvent('music_play', {'song_id': songId});

  Future<void> logSpecialMessageViewed() => logEvent('special_message_viewed');

  Future<void> logCyclePageOpened() => logEvent('cycle_page_opened');

  Future<void> logShare(String contentType) =>
      logEvent('content_shared', {'content_type': contentType});

  Future<void> logGiftOpened(String giftId) =>
      logEvent('gift_opened', {'gift_id': giftId});

  Future<void> logOnboardingComplete() => logEvent('onboarding_complete');
}
