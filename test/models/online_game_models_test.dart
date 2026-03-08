import 'package:flutter_test/flutter_test.dart';
import 'package:where_in_the_world/models/online_game_models.dart';

void main() {
  // ── OnlinePlayer ─────────────────────────────────────────────────────

  group('OnlinePlayer', () {
    test('constructor sets required fields and defaults', () {
      final p = OnlinePlayer(id: 'p1', nickname: 'Alice');
      expect(p.id, 'p1');
      expect(p.nickname, 'Alice');
      expect(p.score, 0);
      expect(p.isHost, false);
      expect(p.isConnected, true);
    });

    test('constructor accepts custom values', () {
      final p = OnlinePlayer(
        id: 'p2',
        nickname: 'Bob',
        score: 15,
        isHost: true,
        isConnected: false,
      );
      expect(p.score, 15);
      expect(p.isHost, true);
      expect(p.isConnected, false);
    });

    test('copyWith updates nickname', () {
      final p = OnlinePlayer(id: 'p1', nickname: 'Alice');
      final p2 = p.copyWith(nickname: 'Alicia');
      expect(p2.id, 'p1'); // preserved
      expect(p2.nickname, 'Alicia');
    });

    test('copyWith updates score', () {
      final p = OnlinePlayer(id: 'p1', nickname: 'Alice', score: 0);
      final p2 = p.copyWith(score: 10);
      expect(p2.score, 10);
    });

    test('toJson contains all fields', () {
      final p = OnlinePlayer(
        id: 'p1',
        nickname: 'Alice',
        score: 5,
        isHost: true,
      );
      final json = p.toJson();
      expect(json['id'], 'p1');
      expect(json['nickname'], 'Alice');
      expect(json['score'], 5);
      expect(json['isHost'], true);
      expect(json['isConnected'], true);
    });

    test('fromJson round-trip', () {
      final original = OnlinePlayer(
        id: 'p1',
        nickname: 'Alice',
        score: 10,
        isHost: true,
      );
      final json = original.toJson();
      final restored = OnlinePlayer.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.nickname, original.nickname);
      expect(restored.score, original.score);
      expect(restored.isHost, original.isHost);
      expect(restored.isConnected, original.isConnected);
    });

    test('fromJson handles missing optional fields', () {
      final p = OnlinePlayer.fromJson({'id': 'x', 'nickname': 'Test'});
      expect(p.score, 0);
      expect(p.isHost, false);
      expect(p.isConnected, true);
    });
  });

  // ── OnlineGameState ──────────────────────────────────────────────────

  group('OnlineGameState', () {
    test('constructor defaults', () {
      final s = OnlineGameState();
      expect(s.currentLandmarkId, isNull);
      expect(s.currentPlayerId, isNull);
      expect(s.currentRound, 1);
      expect(s.totalRounds, 6);
      expect(s.difficulty, 1);
      expect(s.questionsPerTurn, 2);
      expect(s.playerGuesses, isEmpty);
      expect(s.questions, isEmpty);
      expect(s.status, OnlineGameStatus.lobby);
      expect(s.lastRoundWinnerId, isNull);
      expect(s.lastRoundWinReason, isNull);
    });

    test('copyWith updates status', () {
      final s = OnlineGameState();
      final s2 = s.copyWith(status: OnlineGameStatus.playing);
      expect(s2.status, OnlineGameStatus.playing);
      expect(s2.currentRound, 1); // preserved
    });

    test('copyWith updates round and guesses', () {
      final s = OnlineGameState();
      final s2 = s.copyWith(currentRound: 3, playerGuesses: {'p1': 'France'});
      expect(s2.currentRound, 3);
      expect(s2.playerGuesses['p1'], 'France');
    });

    test('toJson/fromJson round-trip', () {
      final original = OnlineGameState(
        currentLandmarkId: 'lm1',
        currentPlayerId: 'p1',
        currentRound: 2,
        totalRounds: 4,
        difficulty: 3,
        questionsPerTurn: 1,
        playerGuesses: {'p1': 'Japan'},
        questions: [
          OnlineQuestion(
            id: 'q1',
            text: 'Is it in Asia?',
            answer: true,
            askedBy: 'p1',
            askedByName: 'Alice',
          ),
        ],
        status: OnlineGameStatus.playing,
        lastRoundWinnerId: 'p1',
        lastRoundWinReason: 'correct',
      );

      final json = original.toJson();
      final restored = OnlineGameState.fromJson(json);

      expect(restored.currentLandmarkId, 'lm1');
      expect(restored.currentPlayerId, 'p1');
      expect(restored.currentRound, 2);
      expect(restored.totalRounds, 4);
      expect(restored.difficulty, 3);
      expect(restored.questionsPerTurn, 1);
      expect(restored.playerGuesses['p1'], 'Japan');
      expect(restored.questions.length, 1);
      expect(restored.questions[0].text, 'Is it in Asia?');
      expect(restored.status, OnlineGameStatus.playing);
      expect(restored.lastRoundWinnerId, 'p1');
      expect(restored.lastRoundWinReason, 'correct');
    });

    test('fromJson handles questions as Map (Firebase format)', () {
      final json = {
        'status': 'playing',
        'currentRound': 1,
        'questions': {
          '0': {
            'id': 'q1',
            'text': 'Is it hot?',
            'answer': true,
            'askedBy': 'p1',
            'askedByName': 'Alice',
          },
        },
      };
      final state = OnlineGameState.fromJson(json);
      expect(state.questions.length, 1);
      expect(state.questions[0].text, 'Is it hot?');
    });

    test('fromJson returns default state on parse failure', () {
      final state = OnlineGameState.fromJson({'playerGuesses': 'invalid'});
      // Should return default state (the catch block), not crash
      expect(state.status, OnlineGameStatus.lobby);
    });
  });

  // ── OnlineQuestion ───────────────────────────────────────────────────

  group('OnlineQuestion', () {
    test('constructor stores all fields', () {
      final q = OnlineQuestion(
        id: 'q1',
        text: 'Is it in Africa?',
        answer: false,
        askedBy: 'p1',
        askedByName: 'Bob',
      );
      expect(q.id, 'q1');
      expect(q.text, 'Is it in Africa?');
      expect(q.answer, false);
      expect(q.askedBy, 'p1');
      expect(q.askedByName, 'Bob');
    });

    test('toJson/fromJson round-trip', () {
      final original = OnlineQuestion(
        id: 'q2',
        text: 'Is it cold?',
        answer: true,
        askedBy: 'p2',
        askedByName: 'Alice',
      );
      final json = original.toJson();
      final restored = OnlineQuestion.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.text, original.text);
      expect(restored.answer, original.answer);
      expect(restored.askedBy, original.askedBy);
      expect(restored.askedByName, original.askedByName);
    });

    test('fromJson handles answer as int 1', () {
      final q = OnlineQuestion.fromJson({
        'id': 'q1',
        'text': 'Test',
        'answer': 1,
        'askedBy': 'p1',
        'askedByName': 'A',
      });
      expect(q.answer, true);
    });

    test('fromJson handles answer as string "true"', () {
      final q = OnlineQuestion.fromJson({
        'id': 'q1',
        'text': 'Test',
        'answer': 'true',
        'askedBy': 'p1',
        'askedByName': 'A',
      });
      expect(q.answer, true);
    });

    test('fromJson handles missing fields gracefully', () {
      final q = OnlineQuestion.fromJson({});
      expect(q.id, '');
      expect(q.text, '');
      expect(q.answer, false);
      expect(q.askedBy, '');
      expect(q.askedByName, 'Unknown');
    });
  });

  // ── OnlineRoom ───────────────────────────────────────────────────────

  group('OnlineRoom', () {
    test('constructor with required fields and defaults', () {
      final room = OnlineRoom(id: 'ABC123', hostId: 'h1', hostName: 'Host');
      expect(room.id, 'ABC123');
      expect(room.hostId, 'h1');
      expect(room.hostName, 'Host');
      expect(room.password, isNull);
      expect(room.players, isEmpty);
      expect(room.isActive, true);
      expect(room.gameState.status, OnlineGameStatus.lobby);
    });

    test('copyWith updates players', () {
      final room = OnlineRoom(id: 'R1', hostId: 'h1', hostName: 'Host');
      final player = OnlinePlayer(id: 'p1', nickname: 'Alice');
      final updated = room.copyWith(players: {'p1': player});
      expect(updated.players.length, 1);
      expect(updated.players['p1']!.nickname, 'Alice');
      expect(updated.id, 'R1'); // preserved
    });

    test('toJson/fromJson round-trip', () {
      final player = OnlinePlayer(id: 'p1', nickname: 'Alice', score: 5);
      final original = OnlineRoom(
        id: 'ROOM01',
        password: 'secret',
        hostId: 'h1',
        hostName: 'Host',
        players: {'p1': player},
        gameState: OnlineGameState(
          status: OnlineGameStatus.playing,
          currentRound: 2,
        ),
        isActive: true,
      );

      final json = original.toJson();
      final restored = OnlineRoom.fromJson(json);

      expect(restored.id, 'ROOM01');
      expect(restored.password, 'secret');
      expect(restored.hostId, 'h1');
      expect(restored.hostName, 'Host');
      expect(restored.players.length, 1);
      expect(restored.players['p1']!.nickname, 'Alice');
      expect(restored.gameState.status, OnlineGameStatus.playing);
      expect(restored.gameState.currentRound, 2);
      expect(restored.isActive, true);
    });

    test('fromJson handles players as List (Firebase edge case)', () {
      final json = {
        'id': 'R1',
        'hostId': 'h1',
        'hostName': 'Host',
        'players': [
          {'id': 'p1', 'nickname': 'Alice', 'score': 0},
        ],
        'isActive': true,
      };
      final room = OnlineRoom.fromJson(json);
      expect(room.players.length, 1);
      expect(room.players['p1']!.nickname, 'Alice');
    });
  });

  // ── OnlineGameStatus enum ────────────────────────────────────────────

  group('OnlineGameStatus', () {
    test('has 4 values', () {
      expect(OnlineGameStatus.values.length, 4);
    });

    test('names match expected strings', () {
      expect(OnlineGameStatus.lobby.name, 'lobby');
      expect(OnlineGameStatus.playing.name, 'playing');
      expect(OnlineGameStatus.roundOver.name, 'roundOver');
      expect(OnlineGameStatus.gameEnded.name, 'gameEnded');
    });
  });
}
