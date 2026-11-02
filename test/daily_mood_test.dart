import 'package:flutter_test/flutter_test.dart';

import 'package:yellow_flowers/features/garden/models/daily_mood.dart';

void main() {
  test('saved indices of the original moods keep their meaning', () {
    // Los ánimos se guardan por índice: los cinco originales no pueden moverse.
    expect(DailyMood.values.take(5), [
      DailyMood.happy,
      DailyMood.calm,
      DailyMood.strong,
      DailyMood.reflective,
      DailyMood.loving,
    ]);
  });

  test('every mood has copy, and only difficult days offer comfort', () {
    for (final mood in DailyMood.values) {
      expect(mood.info.messages, isNotEmpty, reason: mood.name);
      expect(mood.messageFor('Ana'), contains('Ana'), reason: mood.name);
      expect(mood.info.needsComfort, !mood.isBright, reason: mood.name);
    }
  });

  test('fromIndex ignores unknown values', () {
    expect(DailyMoodX.fromIndex(null), isNull);
    expect(DailyMoodX.fromIndex(-1), isNull);
    expect(DailyMoodX.fromIndex(DailyMood.values.length), isNull);
    expect(DailyMoodX.fromIndex(5), DailyMood.sad);
  });
}
