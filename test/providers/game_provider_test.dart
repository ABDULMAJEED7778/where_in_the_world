import 'package:flutter_test/flutter_test.dart';
import 'package:where_in_the_world/providers/game_provider.dart';
import 'package:where_in_the_world/models/game_models.dart';

void main() {
  // Needed for UniqueKey() inside Player constructor
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameProvider provider;

  setUp(() {
    provider = GameProvider();
  });

  tearDown(() {
    provider.dispose();
  });

  // ── Player management ────────────────────────────────────────────────

  group('Player management', () {
    test('addPlayer adds to list', () {
      provider.addPlayer('Alice');
      expect(provider.gameState.players.length, 1);
      expect(provider.gameState.players[0].name, 'Alice');
    });

    test('addPlayer adds multiple players', () {
      provider.addPlayer('Alice');
      provider.addPlayer('Bob');
      provider.addPlayer('Charlie');
      expect(provider.gameState.players.length, 3);
    });

    test('addPlayer caps at 8 players', () {
      for (int i = 0; i < 10; i++) {
        provider.addPlayer('Player $i');
      }
      expect(provider.gameState.players.length, 8);
    });

    test('removePlayer removes by name', () {
      provider.addPlayer('Alice');
      provider.addPlayer('Bob');
      provider.removePlayer('Alice');
      expect(provider.gameState.players.length, 1);
      expect(provider.gameState.players[0].name, 'Bob');
    });

    test('removePlayer with unknown name is no-op', () {
      provider.addPlayer('Alice');
      provider.removePlayer('Unknown');
      expect(provider.gameState.players.length, 1);
    });

    test('adding same name creates 2 separate players', () {
      provider.addPlayer('Alice');
      provider.addPlayer('Alice');
      expect(provider.gameState.players.length, 2);
      // They should have different IDs
      expect(
        provider.gameState.players[0].id,
        isNot(provider.gameState.players[1].id),
      );
    });

    test('addPlayer notifies listeners', () {
      int callCount = 0;
      provider.addListener(() => callCount++);
      provider.addPlayer('Alice');
      expect(callCount, 1);
    });

    test('removePlayer notifies listeners', () {
      provider.addPlayer('Alice');
      int callCount = 0;
      provider.addListener(() => callCount++);
      provider.removePlayer('Alice');
      expect(callCount, 1);
    });
  });

  // ── Settings ─────────────────────────────────────────────────────────

  group('Settings', () {
    test('updateSettings stores new settings', () {
      final settings = GameSettings(
        gameMode: GameMode.singlePlayer,
        difficulty: Difficulty.difficult,
        numberOfRounds: 10,
        questionsPerPlayer: 5,
      );
      provider.updateSettings(settings);
      expect(provider.gameState.settings.gameMode, GameMode.singlePlayer);
      expect(provider.gameState.settings.difficulty, Difficulty.difficult);
      expect(provider.gameState.settings.numberOfRounds, 10);
      expect(provider.gameState.settings.questionsPerPlayer, 5);
    });

    test('updateSettings notifies listeners', () {
      int callCount = 0;
      provider.addListener(() => callCount++);
      provider.updateSettings(
        GameSettings(
          gameMode: GameMode.partyMode,
          difficulty: Difficulty.easy,
          numberOfRounds: 3,
          questionsPerPlayer: 1,
        ),
      );
      expect(callCount, 1);
    });
  });

  // ── Initial state ────────────────────────────────────────────────────

  group('Initial state', () {
    test('starts with empty players', () {
      expect(provider.gameState.players, isEmpty);
    });

    test('starts with no landmark', () {
      expect(provider.gameState.currentLandmark, isNull);
    });

    test('starts at round 1', () {
      expect(provider.gameState.currentRound, 1);
    });

    test('game not started', () {
      expect(provider.gameState.gameStarted, false);
    });

    test('game not ended', () {
      expect(provider.gameState.gameEnded, false);
      expect(provider.gameState.isGameOver, false);
    });

    test('default settings are party mode, easy, 6 rounds, 2 questions', () {
      expect(provider.gameState.settings.gameMode, GameMode.partyMode);
      expect(provider.gameState.settings.difficulty, Difficulty.easy);
      expect(provider.gameState.settings.numberOfRounds, 6);
      expect(provider.gameState.settings.questionsPerPlayer, 2);
    });
  });

  // ── Reset ────────────────────────────────────────────────────────────

  group('resetGame', () {
    test('clears players', () {
      provider.addPlayer('Alice');
      provider.addPlayer('Bob');
      provider.resetGame();
      expect(provider.gameState.players, isEmpty);
    });

    test('resets to default settings', () {
      provider.updateSettings(
        GameSettings(
          gameMode: GameMode.singlePlayer,
          difficulty: Difficulty.difficult,
          numberOfRounds: 10,
          questionsPerPlayer: 5,
        ),
      );
      provider.resetGame();
      expect(provider.gameState.settings.gameMode, GameMode.partyMode);
      expect(provider.gameState.settings.difficulty, Difficulty.easy);
      expect(provider.gameState.settings.numberOfRounds, 6);
    });

    test('resets gameStarted and gameEnded flags', () {
      provider.resetGame();
      expect(provider.gameState.gameStarted, false);
      expect(provider.gameState.gameEnded, false);
    });

    test('notifies listeners', () {
      int callCount = 0;
      provider.addListener(() => callCount++);
      provider.resetGame();
      expect(callCount, 1);
    });
  });

  // NOTE: makeGuess, askQuestion, and startGame tests require DI for
  // PhotosService to set up _gameState with a currentLandmark.
  // These are better covered by integration tests or after adding a
  // @visibleForTesting state setter.

  // ── Events ───────────────────────────────────────────────────────────

  group('Events', () {
    test('events stream is accessible', () {
      expect(provider.events, isNotNull);
    });

    test('events stream is broadcast (can have multiple listeners)', () {
      final sub1 = provider.events.listen((_) {});
      final sub2 = provider.events.listen((_) {});
      // If it's not broadcast, the second listen would throw
      sub1.cancel();
      sub2.cancel();
    });
  });

  // ── Dispose ──────────────────────────────────────────────────────────

  group('Dispose', () {
    test('dispose closes event stream', () async {
      final p = GameProvider();
      final stream = p.events;
      p.dispose();
      // After disposal the stream should complete
      expect(stream, emitsDone);
    });
  });
}
