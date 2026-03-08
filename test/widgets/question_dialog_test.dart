import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:where_in_the_world/widgets/question_dialog.dart';
import 'package:where_in_the_world/providers/game_provider.dart';
import 'package:where_in_the_world/models/game_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps the QuestionDialog inside MaterialApp + Provider.
  Future<GameProvider> pumpDialog(
    WidgetTester tester, {
    List<String> playerNames = const ['Alice'],
  }) async {
    final provider = GameProvider();
    provider.updateSettings(
      GameSettings(
        gameMode: GameMode.partyMode,
        difficulty: Difficulty.easy,
        numberOfRounds: 6,
        questionsPerPlayer: 2,
      ),
    );
    for (final name in playerNames) {
      provider.addPlayer(name);
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: QuestionDialog())),
      ),
    );
    // Use a single pump to render the first frame without waiting for
    // Google Fonts network requests to complete (pumpAndSettle may hang).
    await tester.pump(const Duration(milliseconds: 50));
    return provider;
  }

  // ── UI Rendering Tests ──────────────────────────────────────────────

  group('QuestionDialog UI', () {
    testWidgets('renders title', (tester) async {
      await pumpDialog(tester);
      expect(find.text('Ask a Question'), findsOneWidget);
    });

    testWidgets('shows player name badge', (tester) async {
      await pumpDialog(tester, playerNames: ['Alice']);
      expect(find.text('ALICE'), findsAtLeastNWidgets(1));
    });

    testWidgets('button disabled when input empty', (tester) async {
      await pumpDialog(tester);
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('button enables after typing', (tester) async {
      await pumpDialog(tester);
      await tester.enterText(find.byType(TextField), 'Is it in Europe?');
      await tester.pump();
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows Cancel button', (tester) async {
      await pumpDialog(tester);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows AI helper text', (tester) async {
      await pumpDialog(tester);
      expect(find.textContaining('AI will answer'), findsOneWidget);
    });

    testWidgets('shows yes/no hint text', (tester) async {
      await pumpDialog(tester);
      expect(find.textContaining('yes/no question'), findsOneWidget);
    });

    testWidgets('text field allows multiple lines', (tester) async {
      await pumpDialog(tester);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 3);
    });
  });

  // ── Validation Logic Tests ──────────────────────────────────────────

  group('QuestionDialog validation', () {
    testWidgets('rejects non-yes/no question format', (tester) async {
      await pumpDialog(tester);
      await tester.enterText(find.byType(TextField), 'What country is this?');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();
      expect(find.textContaining('yes/no question'), findsAtLeastNWidgets(1));
    });

    testWidgets('rejects too-short questions', (tester) async {
      await pumpDialog(tester);
      await tester.enterText(find.byType(TextField), 'Is it');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();
      expect(find.textContaining('too short'), findsOneWidget);
    });

    testWidgets('rejects vague "is it?"', (tester) async {
      await pumpDialog(tester);
      await tester.enterText(find.byType(TextField), 'is it?');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();
      expect(find.textContaining('too vague'), findsOneWidget);
    });

    testWidgets('shows error for non-yes/no input', (tester) async {
      await pumpDialog(tester);
      await tester.enterText(find.byType(TextField), 'Tell me the country');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();
      expect(find.textContaining('yes/no question'), findsAtLeastNWidgets(1));
    });
  });
}
