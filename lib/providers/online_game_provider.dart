import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../models/online_game_models.dart';
import '../services/audio_service.dart';
import '../services/photos_service.dart';
import '../services/room_service.dart';
import 'mixins/game_event_mixin.dart';
import 'mixins/game_ai_mixin.dart';
import 'mixins/game_geo_mixin.dart';

/// Provider for managing online multiplayer game state
/// Syncs all game actions to Firebase in real-time
class OnlineGameProvider extends ChangeNotifier
    with GameEventMixin, GameAIMixin, GameGeoMixin {
  final RoomService _roomService = RoomService();
  final PhotosService _photosService = PhotosService();

  StreamSubscription? _roomSubscription;
  OnlineRoom? _room;
  Landmark? _currentLandmark;
  bool _isHost = false;
  bool _isLoading = false;
  bool _initialized = false;
  String? _error;

  Timer? _uiTimer;
  bool _isProcessingTimeout = false;
  String? _lastTimeoutPlayerId;
  bool _isImageLoaded = false;

  int get timeRemaining {
    final endTimeStr = gameState?.turnEndTime;
    if (endTimeStr == null) return 60; // Wait for image to load
    final endTime = DateTime.parse(endTimeStr);
    final remaining = endTime.difference(DateTime.now().toUtc()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  // Getters
  OnlineRoom? get room => _room;
  Landmark? get currentLandmark => _currentLandmark;
  bool get isImageLoaded => _isImageLoaded;
  bool get isHost => _isHost;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;
  String? get error => _error;
  String? get currentPlayerId => _roomService.currentPlayerId;

  // Derived getters
  List<OnlinePlayer> get players => _room?.players.values.toList() ?? [];
  OnlineGameState? get gameState => _room?.gameState;
  int get currentRound => gameState?.currentRound ?? 1;
  int get totalRounds => gameState?.totalRounds ?? 6;
  int get questionsPerTurn => gameState?.questionsPerTurn ?? 2;
  OnlineGameStatus get status => gameState?.status ?? OnlineGameStatus.lobby;
  bool get isPlaying => status == OnlineGameStatus.playing;
  bool get isRoundOver => status == OnlineGameStatus.roundOver;
  bool get isGameEnded => status == OnlineGameStatus.gameEnded;

  // Current player's turn
  OnlinePlayer? get currentTurnPlayer {
    final currentId = gameState?.currentPlayerId;
    if (currentId == null) return null;
    return _room?.players[currentId];
  }

  bool get isMyTurn {
    final turnPlayerId = currentTurnPlayer?.id;
    final myId = currentPlayerId;
    if (turnPlayerId == null || myId == null) return false;
    return turnPlayerId == myId;
  }

  /// Check if a player has already made a guess in the current round
  bool hasGuessed(String playerId) {
    return gameState?.playerGuesses.containsKey(playerId) ?? false;
  }

  // Questions for current round
  List<OnlineQuestion> get questions => gameState?.questions ?? [];

  /// Initialize and listen to room updates
  Future<void> initializeRoom(String roomCode) async {
    print('📦 OnlineGameProvider: Initializing for room $roomCode');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Ensure RoomService has the current info if we're already logged in
      if (_roomService.currentPlayerId != null) {
        _roomService.setPlayerInfo(roomCode, _roomService.currentPlayerId!);
      }

      // Check if current player is host
      final roomInfo = await _roomService.getRoomInfo(roomCode);
      _isHost = roomInfo?.hostId == _roomService.currentPlayerId;
      print(
        '📦 OnlineGameProvider: Host check -> $_isHost (My ID: ${_roomService.currentPlayerId}, Host ID: ${roomInfo?.hostId})',
      );

      // Listen to room changes
      print(
        '📦 OnlineGameProvider: Starting room subscription for $roomCode...',
      );
      _roomSubscription?.cancel();
      _roomSubscription = _roomService
          .listenToRoom(roomCode)
          .listen(
            (room) {
              if (room != null) {
                print(
                  '📡 Room update: status=${room.gameState.status.name}, round=${room.gameState.currentRound}, players=${room.players.length}',
                );
              } else {
                print('📡 Room update: room is NULL (deleted?)');
              }
              _room = room;
              _handleRoomUpdate(room);
              notifyListeners();
            },
            onError: (e) {
              print('❌ OnlineGameProvider: Subscription error: $e');
              _error = e.toString();
              notifyListeners();
            },
          );

      _initialized = true;
    } catch (e) {
      print('❌ OnlineGameProvider: Initialization failed: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle room updates - load landmark if needed
  void _handleRoomUpdate(OnlineRoom? room) async {
    if (room == null) {
      print('🔄 _handleRoomUpdate: room is null');
      return;
    }

    print(
      '🔄 _handleRoomUpdate: status=${room.gameState.status.name}, landmarkId=${room.gameState.currentLandmarkId}',
    );
    print('🔄 _handleRoomUpdate: currentLandmark=${_currentLandmark?.name}');

    // If game just started or new round, load landmark
    if (room.gameState.status == OnlineGameStatus.playing &&
        room.gameState.currentLandmarkId != null &&
        (_currentLandmark == null ||
            _currentLandmark!.name != room.gameState.currentLandmarkId)) {
      print('📦 Loading landmark: ${room.gameState.currentLandmarkId}');
      _isImageLoaded = false;
      await _loadLandmark(room.gameState.currentLandmarkId!);
    } else {
      print('🔄 _handleRoomUpdate: Skipping landmark load');
    }

    _manageUiTimer();
  }

  void onImageLoaded() {
    if (!_isImageLoaded) {
      _isImageLoaded = true;
      notifyListeners();

      // If we're the host and haven't started the turn timer yet, start it now
      if (_isHost &&
          gameState?.turnEndTime == null &&
          status == OnlineGameStatus.playing) {
        if (gameState?.isTimerEnabled == true) {
          final duration = gameState?.turnDurationSeconds ?? 60;
          final newEndTime = DateTime.now()
              .toUtc()
              .add(Duration(seconds: duration))
              .toIso8601String();
          _roomService.updateGameStateFields({'turnEndTime': newEndTime});
        }
      }
    }
  }

  void _manageUiTimer() {
    if (isPlaying && (gameState?.isTimerEnabled ?? true)) {
      if (_uiTimer == null || !_uiTimer!.isActive) {
        _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          notifyListeners();

          final remaining = timeRemaining;
          if (remaining <= 10 &&
              remaining > 0 &&
              gameState?.turnEndTime != null) {
            AudioService().playTimerTick();
          }

          if (remaining <= 0 &&
              _lastTimeoutPlayerId != gameState?.currentPlayerId &&
              gameState?.turnEndTime != null) {
            _lastTimeoutPlayerId = gameState?.currentPlayerId;
            emitTurnTimeout();
            playTimeoutAudio();
          }

          if (_isHost && remaining <= 0 && gameState?.turnEndTime != null) {
            _handleTurnTimeout();
          }
        });
      }
    } else {
      _uiTimer?.cancel();
      _uiTimer = null;
    }
  }

  Future<void> _handleTurnTimeout() async {
    if (_isProcessingTimeout) return;
    _isProcessingTimeout = true;
    try {
      print("⏳ Turn timeout reached! Skipping turn...");

      // Deduct a question by adding a system question
      final currentId = gameState?.currentPlayerId;
      if (currentId != null) {
        final currentQuestionsAsked = questions
            .where((q) => q.askedBy == currentId)
            .length;
        if (currentQuestionsAsked < questionsPerTurn) {
          final systemQuestion = OnlineQuestion(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            askedBy: currentId,
            askedByName: "System",
            text: "(Turn expired)",
            answer: false,
          );
          await _roomService.addQuestion(systemQuestion);
        }
      }

      await _nextTurn();
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isProcessingTimeout = false;
      });
    }
  }

  /// Load landmark by ID
  Future<void> _loadLandmark(String landmarkId) async {
    print('📸 _loadLandmark called with ID: $landmarkId');
    try {
      final landmark = await _photosService.getLandmarkById(landmarkId);
      print(
        '📸 Loaded landmark: ${landmark?.name}, image: ${landmark?.imagePath}',
      );
      _currentLandmark = landmark;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading landmark: $e');
    }
  }

  /// Start the game (host only)
  Future<void> startGame() async {
    if (!_isHost || _room == null) return;

    playGameStartAudio();

    await _startNewRound();
  }

  /// Start a new round (host only)
  Future<void> _startNewRound() async {
    if (!_isHost) return;

    playRoundStartAudio();

    // Get a random landmark
    final difficulty = gameState?.difficulty ?? 1;
    final landmark = await _photosService.getRandomLandmark(
      difficulty: difficulty,
    );

    if (landmark == null) {
      _error = 'No landmarks available';
      notifyListeners();
      return;
    }

    // Randomize turn order
    final playerIds = players.map((p) => p.id).toList();
    playerIds.shuffle(Random());

    // Update game state, leave turnEndTime null until image loads
    final newState = OnlineGameState(
      currentLandmarkId: landmark.name,
      currentPlayerId: playerIds.first,
      currentRound: (gameState?.currentRound ?? 0) + 1,
      totalRounds: gameState?.totalRounds ?? 6,
      difficulty: difficulty,
      questionsPerTurn: gameState?.questionsPerTurn ?? 2,
      playerGuesses: {},
      questions: [],
      status: OnlineGameStatus.playing,
      turnEndTime: null,
      isTimerEnabled: gameState?.nextRoundTimerEnabled ?? true,
      turnDurationSeconds: gameState?.nextRoundTurnDuration ?? 60,
      nextRoundTimerEnabled: gameState?.nextRoundTimerEnabled ?? true,
      nextRoundTurnDuration: gameState?.nextRoundTurnDuration ?? 60,
    );

    await _roomService.updateGameState(newState);
  }

  /// Update timer settings for the next round (host only)
  Future<void> updateNextRoundTimerSettings(bool enabled, int duration) async {
    if (!_isHost) return;
    await _roomService.updateGameStateFields({
      'nextRoundTimerEnabled': enabled,
      'nextRoundTurnDuration': duration,
    });
  }

  /// Ask a question
  Future<void> askQuestion(String questionText) async {
    print('❓ askQuestion START: "$questionText"');
    print(
      '❓ State: landmark=${_currentLandmark?.name}, isMyTurn=$isMyTurn, myId=$currentPlayerId',
    );
    print('❓ RoomId in Service: ${_roomService.currentRoomId}');

    if (_currentLandmark == null) {
      print('❌ askQuestion: Landmark is null');
      return;
    }

    if (!isMyTurn) {
      print(
        '❌ askQuestion: Not my turn (MyId: $currentPlayerId, TurnId: ${gameState?.currentPlayerId})',
      );
      return;
    }

    try {
      AudioService().playQuestionAsked();

      // Get AI answer
      print('🤖 Requesting AI answer for: $questionText');
      final answer = await getAIAnswer(questionText, _currentLandmark!);
      print('🤖 AI response: ${answer ? "YES" : "NO"}');

      // Play answer sound
      playAnswerAudio(answer);

      // Create question
      final myId = currentPlayerId;
      if (myId == null) {
        print('❌ askQuestion: currentPlayerId is null');
        return;
      }

      final player = players.firstWhere(
        (p) => p.id == myId,
        orElse: () {
          print(
            '⚠️ Current player not found in player list! Using fallback name.',
          );
          return OnlinePlayer(id: myId, nickname: 'Me', isHost: false);
        },
      );

      final question = OnlineQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: questionText,
        answer: answer,
        askedBy: myId,
        askedByName: player.nickname,
      );

      // Add question to Firebase
      print('🚀 Adding question to Firebase...');
      await _roomService.addQuestion(question);

      // Move to next turn
      print('⏭ Moving to next turn...');
      await _nextTurn();

      print('✅ askQuestion flow complete');
    } catch (e, stack) {
      print('❌ CRITICAL ERROR in askQuestion: $e');
      print(stack);
    }
  }

  /// Move to next player's turn (called by current player after asking)
  Future<void> _nextTurn() async {
    print('🔄 _nextTurn called (isHost=$_isHost)');
    if (_room == null) {
      print('❌ _nextTurn: No room');
      return;
    }

    final playerIds = players.map((p) => p.id).toList();
    final currentId = gameState?.currentPlayerId;
    final guessedIds = gameState?.playerGuesses.keys.toList() ?? [];

    print('🔄 Finding next player. Current: $currentId, Guessed: $guessedIds');

    // Find next player who hasn't guessed
    int currentIndex = playerIds.indexOf(currentId ?? '');
    String? nextPlayerId;

    for (int i = 1; i <= playerIds.length; i++) {
      int nextIndex = (currentIndex + i) % playerIds.length;
      String candidateId = playerIds[nextIndex];
      if (!guessedIds.contains(candidateId)) {
        nextPlayerId = candidateId;
        break;
      }
    }

    if (nextPlayerId != null) {
      print('✅ Next player: $nextPlayerId');
      final Map<String, dynamic> fields = {'currentPlayerId': nextPlayerId};
      if (gameState?.isTimerEnabled == true) {
        final duration = gameState?.turnDurationSeconds ?? 60;
        fields['turnEndTime'] = DateTime.now()
            .toUtc()
            .add(Duration(seconds: duration))
            .toIso8601String();
      } else {
        fields['turnEndTime'] = null;
      }
      await _roomService.updateGameStateFields(fields);
    } else {
      print('⚠️ No next player found (all have guessed?)');
    }
  }

  /// Make a guess
  Future<void> makeGuess(String country) async {
    if (_currentLandmark == null || currentPlayerId == null) return;

    final correctAnswer = _currentLandmark!.country;
    final isCorrect = country.toLowerCase() == correctAnswer.toLowerCase();

    // Emit event for visual feedback
    if (isCorrect) {
      emitCorrectGuess();
      playCorrectGuessAudio();
    } else {
      emitIncorrectGuess();
    }

    // Submit guess to Firebase
    await _roomService.submitGuess(currentPlayerId!, country);

    // If correct or everyone guessed, end round (host handles this)

    final guesses = Map<String, String>.from(gameState?.playerGuesses ?? {});
    guesses[currentPlayerId!] = country;

    final allGuessed = guesses.length == players.length;
    print('Players: ${players.length}');
    print('Guesses: ${guesses.length}');
    print('Guesses: $guesses');
    print('All guessed: $allGuessed');

    if (isCorrect || allGuessed) {
      print('✅ Correct guess or all guessed');
      await _endRound(guesses, correctAnswer);
    } else {
      if (currentPlayerId == gameState?.currentPlayerId) {
        await _nextTurn();
      }
    }
  }

  /// End the current round and calculate scores
  Future<void> _endRound(
    Map<String, String> guesses,
    String correctAnswer,
  ) async {
    // Calculate scores
    for (final player in players) {
      final guess = guesses[player.id];
      if (guess != null && guess.toLowerCase() == correctAnswer.toLowerCase()) {
        final newScore = player.score + 10;
        await _roomService.updatePlayerScore(player.id, newScore);
      }
    }

    // Check if anyone got it right
    final correctGuesserId = guesses.entries
        .map(
          (e) => MapEntry(
            e.key,
            e.value.toLowerCase() == correctAnswer.toLowerCase(),
          ),
        )
        .where((e) => e.value)
        .map((e) => e.key)
        .firstOrNull;

    String? winnerId;
    String? winReason;

    if (correctGuesserId != null) {
      winnerId = correctGuesserId;
      winReason = 'correct';
    } else {
      playIncorrectGuessAudio();

      // Find nearest guess and award 5 points
      final nearest = findNearestGuessPlayer(guesses, correctAnswer);
      if (nearest != null) {
        playNearestGuessAudio();
        final player = players.firstWhere((p) => p.id == nearest.playerId);
        await _roomService.updatePlayerScore(player.id, player.score + 5);
        winnerId = nearest.playerId;
        winReason = 'nearest';
      }
    }

    await _roomService.updateGameStateFields({
      'status': OnlineGameStatus.roundOver.name,
      if (winnerId != null) 'lastRoundWinnerId': winnerId,
      if (winReason != null) 'lastRoundWinReason': winReason,
    });
  }

  /// Proceed to next round (host only)
  Future<void> proceedToNextRound() async {
    if (!_isHost) return;

    emitRoundTransition();

    if (currentRound < totalRounds) {
      await _startNewRound();
    } else {
      await _endGame();
    }
  }

  /// End the game
  Future<void> _endGame() async {
    if (!_isHost) return;

    playGameEndAudio();

    await _roomService.updateGameStateFields({
      'status': OnlineGameStatus.gameEnded.name,
    });
  }

  /// Get the winner
  OnlinePlayer? get winner {
    if (players.isEmpty) return null;
    return players.reduce((a, b) => a.score > b.score ? a : b);
  }

  /// Leave the game
  Future<void> leaveGame() async {
    _roomSubscription?.cancel();
    await _roomService.leaveRoom();
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _roomSubscription?.cancel();
    disposeEvents();
    super.dispose();
  }
}
