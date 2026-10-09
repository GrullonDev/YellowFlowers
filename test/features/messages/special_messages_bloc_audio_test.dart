// Covers the diagnostic finding that narrated phrases and background music
// never coordinated: speaking a message never paused/ducked whatever was
// already playing, so they could overlap with no coordination at all.
//
// FakeTtsService deliberately does NOT flip state inside speak() itself —
// real flutter_tts resolves speak()'s Future once the native call is
// dispatched, not once speech actually starts; the onStart/onComplete
// callbacks (startSpeaking()/finishSpeaking() here) can arrive well after
// that Future has already completed. A fake that set state synchronously
// inside speak() would hide that race entirely.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yellow_flowers/core/tts/tts_service.dart';
import 'package:yellow_flowers/features/messages/bloc/special_messages_bloc.dart';

class FakeTtsService implements TtsService {
  @override
  final ValueNotifier<TtsState> stateNotifier =
      ValueNotifier(TtsState.stopped);

  String? lastSpoken;

  @override
  TtsState get state => stateNotifier.value;

  @override
  Future<void> speak(String text) async {
    lastSpoken = text;
  }

  /// Simulates the native "speech started" callback.
  void startSpeaking() => stateNotifier.value = TtsState.speaking;

  /// Simulates the native "speech finished" callback.
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
    expect(events, ['pause'],
        reason: 'music must be paused before narration starts');

    // Let _speak's execution past `await _pauseMusic()` so it reaches
    // _speakAndWaitForEnd and registers its listener before the native
    // callbacks "arrive".
    await Future<void>.delayed(Duration.zero);
    expect(fakeTts.lastSpoken, isNotNull);

    fakeTts.startSpeaking();
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
    fakeTts.startSpeaking();
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

    final speakFuture = bloc.speakMessage(bloc.messages.first);
    expect(events, ['pause']);
    await Future<void>.delayed(Duration.zero);

    fakeTts.startSpeaking();
    fakeTts.finishSpeaking();
    await speakFuture;
    expect(events, ['pause', 'resume']);
  });

  test('still waits for a delayed onStart callback before resuming',
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
    // Let speak()'s own Future resolve (the native "dispatch" ack) well
    // before flutter_tts's onStart callback would actually arrive.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(events, ['pause'],
        reason: 'music must still be paused even though onStart has not '
            'fired yet');

    // The delayed onStart arrives now.
    fakeTts.startSpeaking();
    await Future<void>.delayed(Duration.zero);
    expect(events, ['pause'],
        reason: 'must not resume while narration is actually speaking');

    fakeTts.finishSpeaking();
    await speakFuture;
    expect(events, ['pause', 'resume']);
  });

  test(
      'eventually resumes music even if the native completion callback '
      'never fires', () async {
    final fakeTts = FakeTtsService();
    final events = <String>[];
    final bloc = SpecialMessagesBloc(
      ttsService: fakeTts,
      isMusicPlaying: () => true,
      pauseMusic: () async => events.add('pause'),
      resumeMusic: () async => events.add('resume'),
      speechTimeout: const Duration(milliseconds: 20),
    );

    final speakFuture = bloc.speak(0);
    fakeTts.startSpeaking();
    // Never call finishSpeaking() — simulates the OS killing the TTS
    // session without flutter_tts ever reporting completion/cancel/error.

    await speakFuture;
    expect(events, ['pause', 'resume']);
  });

  test(
      'a second speak() waits for the first to fully unwind before '
      'pausing/resuming again', () async {
    final fakeTts = FakeTtsService();
    final events = <String>[];
    final bloc = SpecialMessagesBloc(
      ttsService: fakeTts,
      isMusicPlaying: () => true,
      pauseMusic: () async => events.add('pause'),
      resumeMusic: () async => events.add('resume'),
    );

    final firstSpeak = bloc.speak(0);
    expect(events, ['pause']);
    await Future<void>.delayed(Duration.zero);
    fakeTts.startSpeaking();

    // Interrupt with a second message while the first is still narrating.
    final secondSpeak = bloc.speak(1);

    await firstSpeak;
    expect(events, ['pause', 'resume'],
        reason: 'the first call must fully pause-then-resume before the '
            'second one does anything, never interleaved');

    // Wait until the second call has actually reached TtsService.speak()
    // (and therefore registered its own listener before that call, same
    // as the first) rather than guessing how many microtask hops its
    // interrupt-and-wait machinery needs.
    for (var i = 0; i < 20 && fakeTts.lastSpoken != bloc.messages[1].text; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(fakeTts.lastSpoken, bloc.messages[1].text);

    fakeTts.startSpeaking();
    fakeTts.finishSpeaking();
    await secondSpeak;

    expect(events, ['pause', 'resume', 'pause', 'resume']);
  });
}
