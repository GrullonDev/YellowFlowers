// Covers the diagnostic finding that narrated phrases and background music
// never coordinated: speaking a message never paused/ducked whatever was
// already playing, so they could overlap with no coordination at all.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellow_flowers/core/tts/tts_service.dart';
import 'package:yellow_flowers/features/messages/bloc/special_messages_bloc.dart';

class FakeTtsService implements TtsService {
  @override
  final ValueNotifier<TtsState> stateNotifier = ValueNotifier(TtsState.stopped);

  String? lastSpoken;

  @override
  TtsState get state => stateNotifier.value;

  @override
  Future<void> speak(String text) async {
    lastSpoken = text;
    stateNotifier.value = TtsState.speaking;
  }

  /// Simulates the native "speech finished" callback arriving later.
  void finishSpeaking() => stateNotifier.value = TtsState.stopped;

  @override
  Future<void> stop() async {
    stateNotifier.value = TtsState.stopped;
  }

  @override
  Future<void> toggle(String text) async {}

  @override
  void dispose() => stateNotifier.dispose();
}

void main() {
  test('pauses the music before speaking and resumes once speech ends',
      () async {
    final fakeTts = FakeTtsService();
    final events = <String>[];
    final bloc = SpecialMessagesBloc(
      ttsService: fakeTts,
      isMusicPlaying: () => true,
      pauseMusic: () async => events.add('pause'),
      resumeMusic: () async => events.add('resume'),
    );

    final speakFuture = bloc.speak(0);
    await Future<void>.delayed(Duration.zero);

    expect(events, ['pause'],
        reason: 'music must be paused before narration starts');
    expect(fakeTts.lastSpoken, isNotNull);

    fakeTts.finishSpeaking();
    await speakFuture;

    expect(events, ['pause', 'resume'],
        reason: 'music must resume only after narration actually ends');
  });

  test('leaves music untouched when nothing was playing', () async {
    final fakeTts = FakeTtsService();
    final events = <String>[];
    final bloc = SpecialMessagesBloc(
      ttsService: fakeTts,
      isMusicPlaying: () => false,
      pauseMusic: () async => events.add('pause'),
      resumeMusic: () async => events.add('resume'),
    );

    final speakFuture = bloc.speak(0);
    fakeTts.finishSpeaking();
    await speakFuture;

    expect(events, isEmpty);
  });

  test('speakMessage coordinates audio the same way as speak', () async {
    final fakeTts = FakeTtsService();
    final events = <String>[];
    final bloc = SpecialMessagesBloc(
      ttsService: fakeTts,
      isMusicPlaying: () => true,
      pauseMusic: () async => events.add('pause'),
      resumeMusic: () async => events.add('resume'),
    );

    final speakFuture =
        bloc.speakMessage(bloc.messages.first);
    await Future<void>.delayed(Duration.zero);
    expect(events, ['pause']);

    fakeTts.finishSpeaking();
    await speakFuture;
    expect(events, ['pause', 'resume']);
  });
}
