import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:where_in_the_world/models/game_models.dart';
import 'package:where_in_the_world/providers/mixins/game_event_mixin.dart';

/// Concrete class to test the mixin.
class _TestEvents with GameEventMixin {}

void main() {
  late _TestEvents em;

  setUp(() {
    em = _TestEvents();
  });

  tearDown(() {
    em.disposeEvents();
  });

  group('GameEventMixin', () {
    test('emitCorrectGuess emits correctGuess', () {
      expectLater(em.events, emits(GameEvent.correctGuess));
      em.emitCorrectGuess();
    });

    test('emitIncorrectGuess emits incorrectGuess', () {
      expectLater(em.events, emits(GameEvent.incorrectGuess));
      em.emitIncorrectGuess();
    });

    test('emitRoundTransition emits roundTransition', () {
      expectLater(em.events, emits(GameEvent.roundTransition));
      em.emitRoundTransition();
    });

    test('emitGameEnd emits gameEnd', () {
      expectLater(em.events, emits(GameEvent.gameEnd));
      em.emitGameEnd();
    });

    test('multiple events arrive in order', () {
      final collected = <GameEvent>[];
      em.events.listen(collected.add);

      em.emitCorrectGuess();
      em.emitIncorrectGuess();
      em.emitRoundTransition();

      // Give microtasks time to flush
      expectLater(
        Future.delayed(const Duration(milliseconds: 50), () => collected),
        completion([
          GameEvent.correctGuess,
          GameEvent.incorrectGuess,
          GameEvent.roundTransition,
        ]),
      );
    });

    test('events stream is broadcast (multiple listeners)', () async {
      final events1 = <GameEvent>[];
      final events2 = <GameEvent>[];

      em.events.listen(events1.add);
      em.events.listen(events2.add);

      em.emitCorrectGuess();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(events1, [GameEvent.correctGuess]);
      expect(events2, [GameEvent.correctGuess]);
    });

    test('disposeEvents closes the stream', () async {
      em.disposeEvents();
      // After disposal, adding should not crash but stream is done
      expect(em.events, emitsDone);
    });
  });
}
