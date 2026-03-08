import 'dart:async';
import '../../models/game_models.dart';
import '../../services/audio_service.dart';

/// Mixin providing a shared game event stream and audio helper methods.
///
/// Both [GameProvider] and [OnlineGameProvider] emit [GameEvent]s and play
/// the same audio cues. This mixin centralises that logic.
mixin GameEventMixin {
  final _eventController = StreamController<GameEvent>.broadcast();
  Stream<GameEvent> get events => _eventController.stream;

  // ── Event emitters ──────────────────────────────────────────────────

  void emitCorrectGuess() => _eventController.add(GameEvent.correctGuess);
  void emitIncorrectGuess() => _eventController.add(GameEvent.incorrectGuess);
  void emitTurnTimeout() => _eventController.add(GameEvent.turnTimeout);
  void emitRoundTransition() => _eventController.add(GameEvent.roundTransition);
  void emitGameEnd() => _eventController.add(GameEvent.gameEnd);

  // ── Audio helpers ───────────────────────────────────────────────────

  void playGameStartAudio() {
    AudioService().playGameStart();
    Future.delayed(const Duration(milliseconds: 500), () {
      AudioService().playGameplayMusic();
    });
  }

  void playRoundStartAudio() => AudioService().playRoundStart();

  void playQuestionAudio(bool answer) {
    AudioService().playQuestionAsked();
    // Answer sound is played after AI responds, so callers use playAnswerAudio
  }

  void playAnswerAudio(bool answer) {
    if (answer) {
      AudioService().playAnswerYes();
    } else {
      AudioService().playAnswerNo();
    }
  }

  void playCorrectGuessAudio() => AudioService().playCorrectGuess();
  void playIncorrectGuessAudio() => AudioService().playIncorrectGuess();
  void playTimeoutAudio() => AudioService().playIncorrectGuess();
  void playNearestGuessAudio() => AudioService().playNearestGuess();

  void playGameEndAudio() {
    AudioService().playGameEnd();
    Future.delayed(const Duration(milliseconds: 500), () {
      AudioService().playVictoryMusic();
    });
  }

  // ── Lifecycle ───────────────────────────────────────────────────────

  void disposeEvents() => _eventController.close();
}
