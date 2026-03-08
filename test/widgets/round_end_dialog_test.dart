import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:where_in_the_world/widgets/round_end_dialog.dart';
import 'package:where_in_the_world/models/game_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Helpers ──────────────────────────────────────────────────────────

  /// Creates a GameState configured for round-end testing.
  GameState makeGameState({
    required String country,
    required List<Player> players,
    Map<String, String> playerGuesses = const {},
    GameMode gameMode = GameMode.partyMode,
    int currentRound = 1,
    int numberOfRounds = 6,
  }) {
    return GameState(
      players: players,
      questionsAsked: [],
      currentRoundQuestions: [],
      settings: GameSettings(
        gameMode: gameMode,
        difficulty: Difficulty.easy,
        numberOfRounds: numberOfRounds,
        questionsPerPlayer: 2,
      ),
      gameStarted: true,
      gameEnded: false,
      winner: null,
      playerQuestionCounts: {},
      playersWhoGuessed: [],
      playerGuesses: playerGuesses,
      currentLandmark: Landmark(
        name: 'Eiffel Tower',
        country: country,
        imagePath: '',
        description: '',
      ),
      currentRound: currentRound,
      status: GameStatus.roundOver,
    );
  }

  /// Pumps the RoundEndDialog inside a MaterialApp so it can render.
  Future<void> pumpRoundEndDialog(
    WidgetTester tester, {
    required GameState gameState,
    VoidCallback? onNextRound,
    VoidCallback? onViewScores,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoundEndDialog(
            gameState: gameState,
            onNextRound: onNextRound ?? () {},
            onViewScores: onViewScores ?? () {},
          ),
        ),
      ),
    );
    // Let the entrance animation start
    await tester.pump(const Duration(milliseconds: 100));
  }

  // ── Tests ───────────────────────────────────────────────────────────

  group('RoundEndDialog', () {
    late Player alice;

    setUp(() {
      alice = Player(name: 'Alice');
    });

    testWidgets('shows ROUND OVER header', (tester) async {
      final gs = makeGameState(
        country: 'France',
        players: [alice],
        gameMode: GameMode.singlePlayer,
        playerGuesses: {alice.id: 'France'},
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.textContaining('ROUND OVER'), findsOneWidget);
    });

    testWidgets('displays correct answer country', (tester) async {
      final gs = makeGameState(
        country: 'Japan',
        players: [alice],
        gameMode: GameMode.singlePlayer,
        playerGuesses: {alice.id: 'Japan'},
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.text('JAPAN'), findsOneWidget);
    });

    testWidgets('shows "The Correct Answer Was:" label', (tester) async {
      final gs = makeGameState(
        country: 'Brazil',
        players: [alice],
        gameMode: GameMode.singlePlayer,
        playerGuesses: {alice.id: 'Brazil'},
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.textContaining('Correct Answer'), findsOneWidget);
    });

    testWidgets('single player correct guess shows CORRECT and +10', (
      tester,
    ) async {
      final gs = makeGameState(
        country: 'France',
        players: [alice],
        gameMode: GameMode.singlePlayer,
        playerGuesses: {alice.id: 'France'},
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.textContaining('CORRECT'), findsOneWidget);
      expect(find.text('+10 POINTS'), findsOneWidget);
    });

    testWidgets('single player wrong guess shows NOT QUITE', (tester) async {
      final gs = makeGameState(
        country: 'France',
        players: [alice],
        gameMode: GameMode.singlePlayer,
        playerGuesses: {alice.id: 'Germany'},
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.textContaining('NOT QUITE'), findsOneWidget);
    });

    testWidgets('single player no guess shows TIME UP', (tester) async {
      final gs = makeGameState(
        country: 'France',
        players: [alice],
        gameMode: GameMode.singlePlayer,
        playerGuesses: {},
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.textContaining('TIME UP'), findsOneWidget);
    });

    testWidgets('shows NEXT ROUND when not final round', (tester) async {
      final gs = makeGameState(
        country: 'France',
        players: [alice],
        gameMode: GameMode.singlePlayer,
        playerGuesses: {alice.id: 'France'},
        currentRound: 1,
        numberOfRounds: 6,
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.textContaining('NEXT ROUND'), findsOneWidget);
    });

    testWidgets('shows FINISH GAME on final round', (tester) async {
      final gs = makeGameState(
        country: 'France',
        players: [alice],
        gameMode: GameMode.singlePlayer,
        playerGuesses: {alice.id: 'France'},
        currentRound: 6,
        numberOfRounds: 6,
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.textContaining('FINISH'), findsOneWidget);
    });

    testWidgets('party mode correct guess shows winner name', (tester) async {
      final bob = Player(name: 'Bob');
      final gs = makeGameState(
        country: 'France',
        players: [alice, bob],
        gameMode: GameMode.partyMode,
        playerGuesses: {alice.id: 'Germany', bob.id: 'France'},
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.textContaining('WINNER'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('party mode shows SCORES button', (tester) async {
      final bob = Player(name: 'Bob');
      final gs = makeGameState(
        country: 'France',
        players: [alice, bob],
        gameMode: GameMode.partyMode,
        playerGuesses: {alice.id: 'France', bob.id: 'Germany'},
      );
      await pumpRoundEndDialog(tester, gameState: gs);

      expect(find.textContaining('SCORES'), findsOneWidget);
    });

    testWidgets('onNextRound callback fires on button tap', (tester) async {
      bool called = false;
      final gs = makeGameState(
        country: 'France',
        players: [alice],
        gameMode: GameMode.singlePlayer,
        playerGuesses: {alice.id: 'France'},
      );
      await pumpRoundEndDialog(
        tester,
        gameState: gs,
        onNextRound: () => called = true,
      );

      // Find and tap the NEXT ROUND button
      final nextButton = find.widgetWithText(ElevatedButton, '▶ NEXT ROUND');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pump();

      expect(called, true);
    });
  });
}
