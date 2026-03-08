import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/audio_service.dart';
import '../services/photos_service.dart';
import 'mixins/game_event_mixin.dart';
import 'mixins/game_ai_mixin.dart';
import 'mixins/game_geo_mixin.dart';

class GameProvider extends ChangeNotifier
    with GameEventMixin, GameAIMixin, GameGeoMixin {
  late final PhotosService _photosService;
  final Set<String> _failedLandmarks = {};
  List<String> _turnOrder =
      []; // Randomized order of player IDs for current round

  GameSettings? _nextRoundSettings;
  GameSettings? get nextRoundSettings => _nextRoundSettings;

  void updateNextRoundSettings(GameSettings settings) {
    _nextRoundSettings = settings;
    notifyListeners();
  }

  Timer? _turnTimer;
  int _timeRemaining = 60;
  int get timeRemaining => _timeRemaining;

  void _startTurnTimer() {
    _turnTimer?.cancel();
    if (allQuestionsUsed) return;

    if (!_gameState.settings.isTimerEnabled) {
      _timeRemaining = _gameState.settings.turnDurationSeconds;
      notifyListeners();
      return;
    }

    _timeRemaining = _gameState.settings.turnDurationSeconds;
    notifyListeners();

    _resumeTurnTimer();
  }

  void _resumeTurnTimer() {
    _turnTimer?.cancel();
    if (allQuestionsUsed) return;

    if (!_gameState.settings.isTimerEnabled) {
      return;
    }

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (allQuestionsUsed) {
        timer.cancel();
        return;
      }

      if (_timeRemaining > 0) {
        _timeRemaining--;
        if (_timeRemaining <= 10 && _timeRemaining > 0) {
          AudioService().playTimerTick();
        }
        notifyListeners();
      } else {
        skipTurn();
      }
    });
  }

  void skipTurn() {
    _turnTimer?.cancel();

    // Decrease the remaining questions if possible
    final currentPlayerId = _gameState.currentPlayer?.id;
    if (currentPlayerId != null) {
      final currentCounts = Map<String, int>.from(
        _gameState.playerQuestionCounts,
      );
      final currentCount = currentCounts[currentPlayerId] ?? 0;
      if (currentCount < _gameState.settings.questionsPerPlayer) {
        currentCounts[currentPlayerId] = currentCount + 1;
        _gameState = _gameState.copyWith(playerQuestionCounts: currentCounts);
      }
    }

    emitTurnTimeout();
    playTimeoutAudio();
    _nextTurn();
  }

  GameProvider() {
    _photosService = PhotosService();
  }

  GameState _gameState = GameState(
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

  bool _isImageLoaded = false;
  bool _isTimerPaused = false;

  GameState get gameState => _gameState;
  bool get isImageLoaded => _isImageLoaded;
  bool get isTimerPaused => _isTimerPaused;

  bool get allQuestionsUsed {
    if (_gameState.players.isEmpty) return false;
    for (final player in _gameState.players) {
      final count = _gameState.playerQuestionCounts[player.id] ?? 0;
      if (count < _gameState.settings.questionsPerPlayer) {
        return false;
      }
    }
    return true;
  }

  void onImageLoaded() {
    if (!_isImageLoaded) {
      _isImageLoaded = true;
      notifyListeners();
      _startTurnTimer();
    }
  }

  void pauseTimer() {
    if (!_isTimerPaused) {
      _isTimerPaused = true;
      _turnTimer?.cancel();
      notifyListeners();
    }
  }

  void resumeTimer() {
    if (_isTimerPaused) {
      _isTimerPaused = false;
      notifyListeners();
      _resumeTurnTimer();
    }
  }

  void addPlayer(String name) {
    if (_gameState.players.length < 8) {
      // Max 8 players
      _gameState = _gameState.copyWith(
        players: [
          ..._gameState.players,
          Player(name: name),
        ],
      );
      notifyListeners();
    }
  }

  void removePlayer(String name) {
    _gameState = _gameState.copyWith(
      players: _gameState.players.where((p) => p.name != name).toList(),
    );
    notifyListeners();
  }

  void updateSettings(GameSettings settings) {
    _gameState = _gameState.copyWith(settings: settings);
    notifyListeners();
  }

  Future<void> startGame() async {
    // For single player mode, need at least 1 player. For multiplayer, need at least 2.
    final minPlayers = _gameState.settings.gameMode == GameMode.singlePlayer
        ? 1
        : 2;

    if (_gameState.players.length >= minPlayers) {
      // Set initial scores to 0 for all players
      final initialPlayers = _gameState.players
          .map((p) => p.copyWith(score: 0))
          .toList();

      _gameState = _gameState.copyWith(
        players: initialPlayers,
        gameStarted: true,
        currentRound: 1,
      );

      // Play game start sound and switch to gameplay music
      playGameStartAudio();

      await _startNewRound(); // This will set up the first round
    }
  }

  /// Initialize game data from the photos database
  Future<void> initializeGameData() async {
    try {
      await _photosService.loadLandmarks();
      print('Game data initialized successfully');
    } catch (e) {
      print('Error initializing game data: $e');
    }
  }

  int _getDifficultyLevel() {
    switch (_gameState.settings.difficulty) {
      case Difficulty.easy:
        return 1;
      case Difficulty.moderate:
        return 2;
      case Difficulty.difficult:
        return 3;
    }
  }

  Future<void> _startNewRound() async {
    final landmark = await _photosService.getRandomLandmark(
      excludeLandmarkIds: _failedLandmarks.toList(),
      difficulty: _getDifficultyLevel(),
    );
    print('Difficulty level: ${_getDifficultyLevel()}');

    // Play round start sound
    playRoundStartAudio();

    // Apply next round settings if any exist
    if (_nextRoundSettings != null) {
      _gameState = _gameState.copyWith(settings: _nextRoundSettings);
      _nextRoundSettings = null; // Reset after applying
    }

    // Randomize turn order for this round
    _turnOrder = _gameState.players.map((p) => p.id).toList();
    _turnOrder.shuffle(Random());
    print(
      'Randomized turn order: ${_turnOrder.map((id) => _gameState.players.firstWhere((p) => p.id == id).name).toList()}',
    );

    // Set the first player based on randomized turn order
    final firstPlayer = _gameState.players.firstWhere(
      (p) => p.id == _turnOrder.first,
    );

    _gameState = _gameState.copyWith(
      currentLandmark: landmark,
      currentPlayer: firstPlayer,
      currentRoundQuestions: [],
      playerQuestionCounts: {}, // Reset for the new round
      playersWhoGuessed: [], // Reset for the new round
      playerGuesses: {}, // Reset for the new round
      status: GameStatus.playing,
    );
    _isImageLoaded = false;
    _isTimerPaused = false;
    _turnTimer?.cancel();
    notifyListeners();
  }

  /// Mark a landmark as failed and switch to a different one
  Future<void> switchToNextLandmark() async {
    final currentLandmark = _gameState.currentLandmark;
    if (currentLandmark != null) {
      _failedLandmarks.add(currentLandmark.name);
      print('Marked landmark as failed: ${currentLandmark.name}');
    }

    final newLandmark = await _photosService.getRandomLandmark(
      excludeLandmarkIds: _failedLandmarks.toList(),
      difficulty: _getDifficultyLevel(),
    );

    if (newLandmark != null) {
      _isImageLoaded = false;
      _turnTimer?.cancel();
      _gameState = _gameState.copyWith(currentLandmark: newLandmark);
      notifyListeners();
    } else {
      print('No more landmarks available');
    }
  }

  /// Ask a question and get AI to answer it
  Future<void> askQuestion(String questionText) async {
    final currentPlayer = _gameState.currentPlayer;
    final currentLandmark = _gameState.currentLandmark;

    if (currentPlayer == null || currentLandmark == null) return;

    // Play question asked sound
    AudioService().playQuestionAsked();

    // Get AI answer
    final answer = await getAIAnswer(questionText, currentLandmark);

    // Play answer sound based on result
    playAnswerAudio(answer);

    // Create the question object with AI answer
    final question = Question(
      text: questionText,
      answer: answer,
      askedBy: currentPlayer.name,
    );

    // Update the question counts immutably
    final newQuestionCounts = Map<String, int>.from(
      _gameState.playerQuestionCounts,
    );
    final currentCount = newQuestionCounts[currentPlayer.id] ?? 0;
    newQuestionCounts[currentPlayer.id] = currentCount + 1;

    // Update the game state
    _gameState = _gameState.copyWith(
      questionsAsked: [..._gameState.questionsAsked, question],
      currentRoundQuestions: [..._gameState.currentRoundQuestions, question],
      playerQuestionCounts: newQuestionCounts,
    );

    notifyListeners();

    // Asking a question USES the player's turn.
    _nextTurn();
  }

  void makeGuess(String country, {String? playerId}) {
    // Determine which player is making this guess.
    // If playerId is provided, use that player; otherwise use the current player.
    final Player? guesser = playerId != null
        ? (_gameState.players.where((p) => p.id == playerId).isEmpty
              ? null
              : _gameState.players.where((p) => p.id == playerId).first)
        : _gameState.currentPlayer;

    if (guesser == null) return;

    // Prevent players from guessing more than once
    if (_gameState.playersWhoGuessed.contains(guesser.id)) {
      print(
        'Player ${guesser.name} (${guesser.id}) already guessed. Ignoring guess.',
      );
      return;
    }

    // Emit event for visual feedback immediately
    final correctAnswer = _gameState.currentLandmark?.country;
    if (correctAnswer != null) {
      if (country.toLowerCase() == correctAnswer.toLowerCase()) {
        emitCorrectGuess();
      } else {
        emitIncorrectGuess();
      }
    }

    // --- 1. Prepare the next state's data ---
    // Create the final, complete map of guesses for this round.
    final newPlayerGuesses = Map<String, String>.from(_gameState.playerGuesses);
    newPlayerGuesses[guesser.id] = country;

    // Create the final list of players who have guessed this round.
    final newPlayersWhoGuessed = List<String>.from(_gameState.playersWhoGuessed)
      ..add(guesser.id);

    // Debug: Print the guess being saved
    print('Player ${guesser.name} (${guesser.id}) guessed: $country');
    print('Updated playerGuesses map: $newPlayerGuesses');

    // --- 2. Determine if the round is over ---
    // The round ends if everyone has guessed OR if someone guessed correctly.
    final bool isCorrectGuess =
        country.toLowerCase() ==
        _gameState.currentLandmark!.country.toLowerCase();
    final bool isRoundOver =
        newPlayersWhoGuessed.length == _gameState.players.length ||
        isCorrectGuess;

    if (isRoundOver) {
      // --- ROUND IS OVER ---
      _turnTimer?.cancel();
      final correctAnswer = _gameState.currentLandmark!.country;

      // Calculate new scores based on the FINAL guess map.
      final updatedPlayers = _gameState.players.map((player) {
        final guess = newPlayerGuesses[player.id]; // Use the complete map
        print(
          'Checking player ${player.name} (${player.id}): guess=$guess, correct=$correctAnswer',
        );

        // Direct correct guess: +10 points
        if (guess != null &&
            guess.toLowerCase() == correctAnswer.toLowerCase()) {
          // Play correct guess sound
          playCorrectGuessAudio();
          return player.copyWith(score: player.score + 10);
        }

        return player;
      }).toList();

      // If no one guessed correctly, find the nearest guess
      final bool anyCorrectGuess = _gameState.players.any((player) {
        final guess = newPlayerGuesses[player.id];
        return guess != null &&
            guess.toLowerCase() == correctAnswer.toLowerCase();
      });

      if (!anyCorrectGuess) {
        // Play incorrect guess sound (no one got it right)
        playIncorrectGuessAudio();

        // Only find nearest guess in party mode (multiplayer) - single player doesn't need this
        if (_gameState.settings.gameMode == GameMode.partyMode) {
          // Find the nearest country and award 5 points
          final nearestGuess = findNearestGuessPlayer(
            newPlayerGuesses,
            correctAnswer,
          );
          if (nearestGuess != null) {
            // Play nearest guess sound
            playNearestGuessAudio();

            // Update the player with the nearest guess
            final nearestPlayerId = nearestGuess.playerId;
            final nearestPlayerIndex = updatedPlayers.indexWhere(
              (p) => p.id == nearestPlayerId,
            );
            if (nearestPlayerIndex >= 0) {
              updatedPlayers[nearestPlayerIndex] =
                  updatedPlayers[nearestPlayerIndex].copyWith(
                    score: updatedPlayers[nearestPlayerIndex].score + 5,
                  );
              print(
                'Nearest guess found: ${newPlayerGuesses[nearestPlayerId]} by player ${_gameState.players.firstWhere((p) => p.id == nearestPlayerId).name}, distance: ${nearestGuess.distance} km',
              );
            }
          }
        }
      }

      // Perform a SINGLE state update with ALL final data.
      _gameState = _gameState.copyWith(
        players: updatedPlayers,
        playerGuesses: newPlayerGuesses,
        playersWhoGuessed: newPlayersWhoGuessed,
        status: GameStatus.roundOver,
      );

      // Call notifyListeners after updating state
      notifyListeners();
    } else {
      // --- ROUND CONTINUES ---
      // Update the state FIRST. Note: guessing does NOT always consume the turn.
      _gameState = _gameState.copyWith(
        playerGuesses: newPlayerGuesses,
        playersWhoGuessed: newPlayersWhoGuessed,
      );

      // If the guesser was the current player, advance the turn. Otherwise keep the
      // currentPlayer unchanged (so guessing is independent of turn).
      if (guesser.id == _gameState.currentPlayer?.id) {
        _nextTurn();
      } else {
        notifyListeners();
      }
    }
  }

  /// Moves to the next player in the randomized turn order who has not yet guessed.
  void _nextTurn() {
    if (allQuestionsUsed) {
      _turnTimer?.cancel();
      notifyListeners();
      return;
    }

    final players = _gameState.players;
    final currentPlayerId = _gameState.currentPlayer?.id;
    if (currentPlayerId == null || _turnOrder.isEmpty) return;

    // Find current player's position in the turn order
    int currentIndex = _turnOrder.indexWhere((id) => id == currentPlayerId);
    int nextIndex = currentIndex;

    // Loop to find the next available player in turn order
    do {
      nextIndex = (nextIndex + 1) % _turnOrder.length;
    } while (_gameState.playersWhoGuessed.contains(_turnOrder[nextIndex]));

    // Get the player object from the turn order ID
    final nextPlayer = players.firstWhere((p) => p.id == _turnOrder[nextIndex]);

    _gameState = _gameState.copyWith(currentPlayer: nextPlayer);
    notifyListeners();
    _startTurnTimer();
  }

  /// Proceeds to the next round or ends the game.
  Future<void> proceedToNextRound() async {
    emitRoundTransition();
    if (_gameState.currentRound < _gameState.settings.numberOfRounds) {
      _gameState = _gameState.copyWith(
        currentRound: _gameState.currentRound + 1,
      );
      await _startNewRound();
    } else {
      _endGame();
    }
  }

  void _endGame() {
    _turnTimer?.cancel();
    // Find the player with the highest score
    if (_gameState.players.isEmpty) return;
    final winner = _gameState.players.reduce(
      (a, b) => a.score > b.score ? a : b,
    );

    // Play game end sound and victory music
    playGameEndAudio();

    _gameState = _gameState.copyWith(gameEnded: true, winner: winner.name);
    notifyListeners();
  }

  /// Public accessor for ending the game, used by integration tests.
  void forceEndGame() => _endGame();

  void resetGame() {
    _turnTimer?.cancel();
    _gameState = GameState(
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
    _failedLandmarks.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    disposeEvents();
    super.dispose();
  }
}
