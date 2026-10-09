// Covers the diagnostic finding that "suggested phrases" never existed as a
// user-facing choice — DefaultMessages.getRandom() only ever fired silently
// as a fallback when the dedication field was left empty.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/features/flowers/bloc/flower_bloc.dart';
import 'package:yellow_flowers/features/flowers/models/default_messages.dart';
import 'package:yellow_flowers/features/flowers/widgets/name_entry_flower.dart';

void main() {
  testWidgets('tapping a suggested phrase fills the dedication field',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FlowerBloc>(
        create: (_) => FlowerBloc(),
        child: const MaterialApp(home: NameEntryFlower()),
      ),
    );
    await tester.pump();

    final firstPhrase = DefaultMessages.poeticMessages.first;
    final chip = find.text(firstPhrase);
    expect(chip, findsOneWidget,
        reason: 'suggested phrases must be visible, not just a hidden '
            'random fallback');

    // Scroll the suggested-phrase chip into view. NameEntryFlower's
    // background has an infinite ..repeat() animation, so pumpAndSettle()
    // (and ensureVisible(), which relies on it) would hang here — scroll
    // manually with a bounded pump instead.
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -400));
    await tester.pump();

    await tester.tap(chip);
    await tester.pump();

    final bloc = Provider.of<FlowerBloc>(
        tester.element(find.byType(NameEntryFlower)),
        listen: false);
    expect(bloc.dedicationController.text, firstPhrase);
  });
}
