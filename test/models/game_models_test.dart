import 'package:flutter_test/flutter_test.dart';
import 'package:where_in_the_world/models/game_models.dart';

void main() {
  // Needed for UniqueKey() inside Player constructor
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Player ───────────────────────────────────────────────────────────

  group('Player', () {
    test('constructor sets name and default score 0', () {
      final p = Player(name: 'Alice');
      expect(p.name, 'Alice');
      expect(p.score, 0);
    });

    test('constructor generates a unique id', () {
      final p1 = Player(name: 'A');
      final p2 = Player(name: 'B');
      expect(p1.id, isNotEmpty);
      expect(p1.id, isNot(p2.id));
    });

    test('constructor accepts custom score', () {
      final p = Player(name: 'Bob', score: 42);
      expect(p.score, 42);
    });

    test('copyWith preserves id', () {
      final p = Player(name: 'Alice');
      final p2 = p.copyWith(name: 'Bob');
      expect(p2.id, p.id);
    });

    test('copyWith updates name', () {
      final p = Player(name: 'Alice');
      final p2 = p.copyWith(name: 'Bob');
      expect(p2.name, 'Bob');
      expect(p2.score, p.score);
    });

    test('copyWith updates score', () {
      final p = Player(name: 'Alice', score: 5);
      final p2 = p.copyWith(score: 10);
      expect(p2.score, 10);
      expect(p2.name, 'Alice');
    });

    test('copyWith with no args returns identical clone', () {
      final p = Player(name: 'Alice', score: 7);
      final p2 = p.copyWith();
      expect(p2.id, p.id);
      expect(p2.name, p.name);
      expect(p2.score, p.score);
    });
  });

  // ── Question ─────────────────────────────────────────────────────────

  group('Question', () {
    test('constructor stores text, answer, askedBy', () {
      final q = Question(
        text: 'Is it in Europe?',
        answer: true,
        askedBy: 'Alice',
      );
      expect(q.text, 'Is it in Europe?');
      expect(q.answer, true);
      expect(q.askedBy, 'Alice');
    });

    test('answer false is stored correctly', () {
      final q = Question(text: 'Is it hot?', answer: false, askedBy: 'Bob');
      expect(q.answer, false);
    });
  });

  // ── Landmark ─────────────────────────────────────────────────────────

  group('Landmark', () {
    test('constructor stores all fields', () {
      final l = Landmark(
        name: 'Eiffel Tower',
        country: 'France',
        imagePath: '/images/eiffel.jpg',
        description: 'Iconic tower in Paris',
        difficulty: 2,
      );
      expect(l.name, 'Eiffel Tower');
      expect(l.country, 'France');
      expect(l.imagePath, '/images/eiffel.jpg');
      expect(l.description, 'Iconic tower in Paris');
      expect(l.difficulty, 2);
    });

    test('default difficulty is 1', () {
      final l = Landmark(
        name: 'Test',
        country: 'Test',
        imagePath: '',
        description: '',
      );
      expect(l.difficulty, 1);
    });
  });

  // ── GameSettings ─────────────────────────────────────────────────────

  group('GameSettings', () {
    test('constructor stores all fields', () {
      final s = GameSettings(
        gameMode: GameMode.singlePlayer,
        difficulty: Difficulty.moderate,
        numberOfRounds: 3,
        questionsPerPlayer: 4,
      );
      expect(s.gameMode, GameMode.singlePlayer);
      expect(s.difficulty, Difficulty.moderate);
      expect(s.numberOfRounds, 3);
      expect(s.questionsPerPlayer, 4);
    });
  });

  // ── GameState ────────────────────────────────────────────────────────

  group('GameState', () {
    late GameState defaultState;

    setUp(() {
      defaultState = GameState(
        players: [],
        questionsAsked: [],
        currentRoundQuestions: [],
        settings: GameSettings(
          gameMode: GameMode.partyMode,
          difficulty: Difficulty.easy,
          numberOfRounds: 6,
          questionsPerPlayer: 2,
        ),
      );
    });

    test('default values are correct', () {
      expect(defaultState.players, isEmpty);
      expect(defaultState.questionsAsked, isEmpty);
      expect(defaultState.currentRoundQuestions, isEmpty);
      expect(defaultState.currentLandmark, isNull);
      expect(defaultState.currentPlayer, isNull);
      expect(defaultState.currentRound, 1);
      expect(defaultState.gameStarted, false);
      expect(defaultState.gameEnded, false);
      expect(defaultState.winner, isNull);
      expect(defaultState.playerQuestionCounts, isEmpty);
      expect(defaultState.playersWhoGuessed, isEmpty);
      expect(defaultState.playerGuesses, isEmpty);
      expect(defaultState.status, GameStatus.playing);
    });

    test('isGameOver returns gameEnded', () {
      expect(defaultState.isGameOver, false);
      final ended = defaultState.copyWith(gameEnded: true);
      expect(ended.isGameOver, true);
    });

    test('copyWith updates players', () {
      final p = Player(name: 'Alice');
      final updated = defaultState.copyWith(players: [p]);
      expect(updated.players.length, 1);
      expect(updated.players[0].name, 'Alice');
    });

    test('copyWith preserves unmodified fields', () {
      final updated = defaultState.copyWith(currentRound: 3);
      expect(updated.currentRound, 3);
      expect(updated.gameStarted, false);
      expect(updated.settings.gameMode, GameMode.partyMode);
    });

    test('copyWith updates status', () {
      final updated = defaultState.copyWith(status: GameStatus.roundOver);
      expect(updated.status, GameStatus.roundOver);
    });

    test('copyWith updates winner', () {
      final updated = defaultState.copyWith(winner: 'Alice', gameEnded: true);
      expect(updated.winner, 'Alice');
      expect(updated.gameEnded, true);
    });

    test('copyWith updates playerGuesses', () {
      final updated = defaultState.copyWith(playerGuesses: {'p1': 'France'});
      expect(updated.playerGuesses['p1'], 'France');
    });
  });

  // ── Enums ────────────────────────────────────────────────────────────

  group('Enums', () {
    test('GameMode has 2 values', () {
      expect(GameMode.values.length, 2);
      expect(GameMode.values, contains(GameMode.singlePlayer));
      expect(GameMode.values, contains(GameMode.partyMode));
    });

    test('Difficulty has 3 values', () {
      expect(Difficulty.values.length, 3);
      expect(Difficulty.values, contains(Difficulty.easy));
      expect(Difficulty.values, contains(Difficulty.moderate));
      expect(Difficulty.values, contains(Difficulty.difficult));
    });

    test('GameStatus has 2 values', () {
      expect(GameStatus.values.length, 2);
      expect(GameStatus.values, contains(GameStatus.playing));
      expect(GameStatus.values, contains(GameStatus.roundOver));
    });

    test('GameEvent has 4 values', () {
      expect(GameEvent.values.length, 4);
      expect(GameEvent.values, contains(GameEvent.correctGuess));
      expect(GameEvent.values, contains(GameEvent.incorrectGuess));
      expect(GameEvent.values, contains(GameEvent.roundTransition));
      expect(GameEvent.values, contains(GameEvent.gameEnd));
    });
  });
}
