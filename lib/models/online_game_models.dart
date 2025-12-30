/// Data models for online multiplayer functionality

/// Represents a player in an online multiplayer room
class OnlinePlayer {
  final String id; // Unique session ID
  final String nickname;
  final int score;
  final bool isHost;
  final bool isConnected;

  OnlinePlayer({
    required this.id,
    required this.nickname,
    this.score = 0,
    this.isHost = false,
    this.isConnected = true,
  });

  OnlinePlayer copyWith({
    String? nickname,
    int? score,
    bool? isHost,
    bool? isConnected,
  }) {
    return OnlinePlayer(
      id: id,
      nickname: nickname ?? this.nickname,
      score: score ?? this.score,
      isHost: isHost ?? this.isHost,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'score': score,
      'isHost': isHost,
      'isConnected': isConnected,
    };
  }

  factory OnlinePlayer.fromJson(Map<String, dynamic> json) {
    return OnlinePlayer(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      score: json['score'] as int? ?? 0,
      isHost: json['isHost'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? true,
    );
  }
}

/// Current state of an online game
class OnlineGameState {
  final String? currentLandmarkId;
  final String? currentPlayerId;
  final int currentRound;
  final int totalRounds;
  final int difficulty;
  final int questionsPerTurn;
  final Map<String, String> playerGuesses;
  final List<OnlineQuestion> questions;
  final OnlineGameStatus status;
  final String? lastRoundWinnerId; // ID of the winner (correct or nearest)
  final String? lastRoundWinReason; // 'correct' or 'nearest'

  OnlineGameState({
    this.currentLandmarkId,
    this.currentPlayerId,
    this.currentRound = 1,
    this.totalRounds = 6,
    this.difficulty = 1,
    this.questionsPerTurn = 2,
    this.playerGuesses = const {},
    this.questions = const [],
    this.status = OnlineGameStatus.lobby,
    this.lastRoundWinnerId,
    this.lastRoundWinReason,
  });

  OnlineGameState copyWith({
    String? currentLandmarkId,
    String? currentPlayerId,
    int? currentRound,
    int? totalRounds,
    int? difficulty,
    int? questionsPerTurn,
    Map<String, String>? playerGuesses,
    List<OnlineQuestion>? questions,
    OnlineGameStatus? status,
    String? lastRoundWinnerId,
    String? lastRoundWinReason,
  }) {
    return OnlineGameState(
      currentLandmarkId: currentLandmarkId ?? this.currentLandmarkId,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      difficulty: difficulty ?? this.difficulty,
      questionsPerTurn: questionsPerTurn ?? this.questionsPerTurn,
      playerGuesses: playerGuesses ?? this.playerGuesses,
      questions: questions ?? this.questions,
      status: status ?? this.status,
      lastRoundWinnerId: lastRoundWinnerId ?? this.lastRoundWinnerId,
      lastRoundWinReason: lastRoundWinReason ?? this.lastRoundWinReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLandmarkId': currentLandmarkId,
      'currentPlayerId': currentPlayerId,
      'currentRound': currentRound,
      'totalRounds': totalRounds,
      'difficulty': difficulty,
      'questionsPerTurn': questionsPerTurn,
      'playerGuesses': playerGuesses,
      'questions': questions.map((q) => q.toJson()).toList(),
      'status': status.name,
      'lastRoundWinnerId': lastRoundWinnerId,
      'lastRoundWinReason': lastRoundWinReason,
    };
  }

  factory OnlineGameState.fromJson(Map<String, dynamic> json) {
    try {
      final questionsData = json['questions'];
      List<OnlineQuestion> questions = [];
      if (questionsData != null) {
        if (questionsData is List) {
          questions = questionsData
              .where((q) => q != null)
              .map(
                (q) => OnlineQuestion.fromJson(
                  Map<String, dynamic>.from(q as Map),
                ),
              )
              .toList();
        } else if (questionsData is Map) {
          questions = questionsData.values
              .where((q) => q != null)
              .map(
                (q) => OnlineQuestion.fromJson(
                  Map<String, dynamic>.from(q as Map),
                ),
              )
              .toList();
        }
      }

      final guessesData = json['playerGuesses'];
      Map<String, String> guesses = {};
      if (guessesData != null && guessesData is Map) {
        guesses = Map<String, String>.from(guessesData);
      }

      final statusStr = json['status'] as String? ?? 'lobby';
      final status = OnlineGameStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => OnlineGameStatus.lobby,
      );

      return OnlineGameState(
        currentLandmarkId: json['currentLandmarkId'] as String?,
        currentPlayerId: json['currentPlayerId'] as String?,
        currentRound: json['currentRound'] as int? ?? 1,
        totalRounds: json['totalRounds'] as int? ?? 6,
        difficulty: json['difficulty'] as int? ?? 1,
        questionsPerTurn: json['questionsPerTurn'] as int? ?? 2,
        playerGuesses: guesses,
        questions: questions,
        status: status,
        lastRoundWinnerId: json['lastRoundWinnerId'] as String?,
        lastRoundWinReason: json['lastRoundWinReason'] as String?,
      );
    } catch (e, stack) {
      print('❌ ERROR parsing OnlineGameState: $e');
      print(stack);
      // Return a basic state if parsing fails to avoid crashing the stream
      return OnlineGameState();
    }
  }
}

/// A question asked during an online game
class OnlineQuestion {
  final String id;
  final String text;
  final bool answer;
  final String askedBy; // Player ID who asked
  final String askedByName; // Player nickname

  OnlineQuestion({
    required this.id,
    required this.text,
    required this.answer,
    required this.askedBy,
    required this.askedByName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'answer': answer,
      'askedBy': askedBy,
      'askedByName': askedByName,
    };
  }

  factory OnlineQuestion.fromJson(Map<String, dynamic> json) {
    return OnlineQuestion(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      answer:
          json['answer'] == true ||
          json['answer'] == 1 ||
          json['answer'] == 'true',
      askedBy: (json['askedBy'] ?? '').toString(),
      askedByName: (json['askedByName'] ?? 'Unknown').toString(),
    );
  }
}

/// Represents an online multiplayer room
class OnlineRoom {
  final String id; // 6-char alphanumeric code
  final String? password; // Optional password (hashed)
  final String hostId; // Creator's session ID
  final String hostName;
  final Map<String, OnlinePlayer> players;
  final OnlineGameState gameState;
  final DateTime createdAt;
  final bool isActive;

  OnlineRoom({
    required this.id,
    this.password,
    required this.hostId,
    required this.hostName,
    this.players = const {},
    OnlineGameState? gameState,
    DateTime? createdAt,
    this.isActive = true,
  }) : gameState = gameState ?? OnlineGameState(),
       createdAt = createdAt ?? DateTime.now();

  OnlineRoom copyWith({
    String? password,
    String? hostId,
    String? hostName,
    Map<String, OnlinePlayer>? players,
    OnlineGameState? gameState,
    bool? isActive,
  }) {
    return OnlineRoom(
      id: id,
      password: password ?? this.password,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      players: players ?? this.players,
      gameState: gameState ?? this.gameState,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'hostId': hostId,
      'hostName': hostName,
      'players': players.map((key, value) => MapEntry(key, value.toJson())),
      'gameState': gameState.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory OnlineRoom.fromJson(Map<String, dynamic> json) {
    try {
      final playersData = json['players'];
      Map<String, OnlinePlayer> players = {};
      if (playersData != null) {
        if (playersData is Map) {
          players = playersData.map(
            (key, value) => MapEntry(
              key as String,
              OnlinePlayer.fromJson(Map<String, dynamic>.from(value as Map)),
            ),
          );
        } else if (playersData is List) {
          // If Firebase converts to list, the ID might be inside or we use index as fallback
          for (int i = 0; i < playersData.length; i++) {
            if (playersData[i] != null) {
              final p = OnlinePlayer.fromJson(
                Map<String, dynamic>.from(playersData[i] as Map),
              );
              players[p.id] = p;
            }
          }
        }
      }

      final room = OnlineRoom(
        id: json['id'] as String? ?? '',
        password: json['password'] as String?,
        hostId: json['hostId'] as String? ?? '',
        hostName: json['hostName'] as String? ?? 'Unknown',
        players: players,
        gameState: json['gameState'] != null
            ? OnlineGameState.fromJson(
                Map<String, dynamic>.from(json['gameState'] as Map),
              )
            : OnlineGameState(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        isActive: json['isActive'] == true,
      );
      return room;
    } catch (e, stack) {
      print('❌ ERROR parsing OnlineRoom: $e');
      print(stack);
      rethrow;
    }
  }
}

/// Status of an online game
enum OnlineGameStatus {
  lobby, // Waiting for players
  playing, // Game in progress
  roundOver, // Showing round results
  gameEnded, // Game finished
}
