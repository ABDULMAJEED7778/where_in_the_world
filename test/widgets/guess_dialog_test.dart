import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:where_in_the_world/widgets/guess_dialog.dart';
import 'package:where_in_the_world/providers/game_provider.dart';
import 'package:where_in_the_world/models/game_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Helpers ──────────────────────────────────────────────────────────

  /// Pumps the GuessDialog with a configured provider.
  Future<GameProvider> pumpGuessDialog(
    WidgetTester tester, {
    GameMode gameMode = GameMode.partyMode,
    List<String> playerNames = const ['Alice', 'Bob'],
  }) async {
    final provider = GameProvider();
    provider.updateSettings(
      GameSettings(
        gameMode: gameMode,
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
        child: const MaterialApp(home: Scaffold(body: GuessDialog())),
      ),
    );
    await tester.pumpAndSettle();
    return provider;
  }

  // ── Tests ───────────────────────────────────────────────────────────

  group('GuessDialog', () {
    testWidgets('renders "Make Your Guess" title', (tester) async {
      await pumpGuessDialog(tester);
      expect(find.text('Make Your Guess'), findsOneWidget);
    });

    testWidgets('shows current player name in badge', (tester) async {
      await pumpGuessDialog(tester, playerNames: ['Alice', 'Bob']);
      expect(find.text('ALICE'), findsAtLeastNWidgets(1));
    });

    testWidgets('GUESS button is disabled when input is empty', (tester) async {
      await pumpGuessDialog(tester);
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('GUESS button enables after typing text', (tester) async {
      await pumpGuessDialog(tester);
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'France');
      await tester.pump();
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows warning message about no cancel', (tester) async {
      await pumpGuessDialog(tester);
      expect(find.textContaining('cannot cancel'), findsOneWidget);
    });

    testWidgets('shows CANCEL button', (tester) async {
      await pumpGuessDialog(tester);
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('shows warning icon', (tester) async {
      await pumpGuessDialog(tester);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('hides player dropdown in single player mode', (tester) async {
      await pumpGuessDialog(
        tester,
        gameMode: GameMode.singlePlayer,
        playerNames: ['Solo'],
      );
      expect(find.textContaining('Guessing as'), findsNothing);
    });

    testWidgets('shows player dropdown in party mode with 2+ players', (
      tester,
    ) async {
      await pumpGuessDialog(
        tester,
        gameMode: GameMode.partyMode,
        playerNames: ['Alice', 'Bob'],
      );
      expect(find.textContaining('Guessing as'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('shows country hint text in input field', (tester) async {
      await pumpGuessDialog(tester);
      expect(find.textContaining('country name'), findsOneWidget);
    });
  });
}
