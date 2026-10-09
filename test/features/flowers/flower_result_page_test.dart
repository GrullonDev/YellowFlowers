// Covers the diagnostic finding that the flower style chosen in
// NameEntryFlower (daisy/sunflower/rose) never affected the bouquet shown
// on FlowerResultPage — the choice was purely cosmetic UI with no effect.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_result_page.dart';
import 'package:yellow_flowers/features/garden/widgets/growing_flower.dart';

Future<List<Color>> _petalColorsFor(
    WidgetTester tester, FlowerTheme theme) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<PersonalizationService>(
      PersonalizationService(prefs));
  addTearDown(sl.reset);

  await tester.pumpWidget(MaterialApp(
    home: FlowerResultPage(
      sender: 'Ana',
      recipient: 'Luz',
      dedication: 'Hola',
      theme: theme,
      mood: Mood.joy,
    ),
  ));
  await tester.pump();
  // Flush the entrance/grow timer chain scheduled in initState so it
  // doesn't leak a pending Timer past the end of the test.
  await tester.pump(const Duration(milliseconds: 2200));

  return tester
      .widgetList<GrowingFlower>(find.byType(GrowingFlower))
      .map((w) => w.variant.petalColor)
      .toList();
}

void main() {
  testWidgets('sunflower theme renders the sunflower palette',
      (tester) async {
    final colors = await _petalColorsFor(tester, FlowerTheme.sunflower);
    expect(colors, contains(const Color(0xFFFFE082)));
  });

  testWidgets('daisy theme renders the daisy palette', (tester) async {
    final colors = await _petalColorsFor(tester, FlowerTheme.daisy);
    expect(colors, contains(const Color(0xFFFFFDF7)));
    expect(colors, isNot(contains(const Color(0xFFFFE082))));
  });

  testWidgets('rose theme renders the rose palette', (tester) async {
    final colors = await _petalColorsFor(tester, FlowerTheme.rose);
    expect(colors, contains(const Color(0xFFEF9A9A)));
    expect(colors, isNot(contains(const Color(0xFFFFE082))));
  });
}
