import 'package:flutter/material.dart';

class Player {
  final String id;
  final String name;
  int score;

  // Primary constructor that generates a new ID
  Player({required this.name, this.score = 0}) : id = UniqueKey().toString();

  // Private named constructor that accepts an ID (for copyWith)
  Player._({required this.id, required this.name, required this.score});

  Player copyWith({String? name, int? score}) {
    // Use the private constructor to preserve the original ID
    return Player._(
      id: id, // ✅ Preserve the original ID
      name: name ?? this.name,
      score: score ?? this.score,
    );
  }
}

class Question {
  final String text;
  final bool answer;
  final String askedBy;

  Question({required this.text, required this.answer, required this.askedBy});
}

class Landmark {
  final String name;
  final String country;
  final String imagePath;
  final String description;
  final int difficulty;

  Landmark({
    required this.name,
    required this.country,
    required this.imagePath,
    required this.description,
    this.difficulty = 1,
  });
}

class GameSettings {
  final GameMode gameMode;
  final Difficulty difficulty;
  final int numberOfRounds;
  final int questionsPerPlayer;

  GameSettings({
    required this.gameMode,
    required this.difficulty,
    required this.numberOfRounds,
    required this.questionsPerPlayer,
  });
}

enum GameMode { singlePlayer, partyMode }

enum Difficulty { easy, moderate, difficult }

class GameState {
  final List<Player> players;
  final List<Question> questionsAsked;
  final List<Question> currentRoundQuestions;
  final Map<String, int> playerQuestionCounts;
  final Map<String, String> playerGuesses;
  final GameStatus status;
  final List<String> playersWhoGuessed;
  final Landmark? currentLandmark;
  final Player? currentPlayer;
  final int currentRound;
  final GameSettings settings;
  final bool gameStarted;
  final bool gameEnded;
  final String? winner;

  GameState({
    required this.players,
    required this.questionsAsked,
    required this.currentRoundQuestions,
    this.currentLandmark,
    this.currentPlayer,
    this.currentRound = 1,
    required this.settings,
    this.gameStarted = false,
    this.gameEnded = false,
    this.winner,
    this.playerQuestionCounts = const {},
    this.playersWhoGuessed = const [],
    this.playerGuesses = const {},
    this.status = GameStatus.playing,
  });

  bool get isGameOver => gameEnded;

  GameState copyWith({
    List<Player>? players,
    List<Question>? questionsAsked,
    List<Question>? currentRoundQuestions,
    Landmark? currentLandmark,
    Player? currentPlayer,
    int? currentRound,
    GameSettings? settings,
    bool? gameStarted,
    bool? gameEnded,
    String? winner,
    Map<String, int>? playerQuestionCounts,
    List<String>? playersWhoGuessed,
    Map<String, String>? playerGuesses,
    GameStatus? status,
  }) {
    return GameState(
      players: players ?? this.players,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      currentRoundQuestions:
          currentRoundQuestions ?? this.currentRoundQuestions,
      currentLandmark: currentLandmark ?? this.currentLandmark,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      currentRound: currentRound ?? this.currentRound,
      settings: settings ?? this.settings,
      gameStarted: gameStarted ?? this.gameStarted,
      gameEnded: gameEnded ?? this.gameEnded,
      winner: winner ?? this.winner,
      playerQuestionCounts: playerQuestionCounts ?? this.playerQuestionCounts,
      playersWhoGuessed: playersWhoGuessed ?? this.playersWhoGuessed,
      playerGuesses: playerGuesses ?? this.playerGuesses,
      status: status ?? this.status,
    );
  }
}

enum GameStatus { playing, roundOver }

enum GameEvent { correctGuess, incorrectGuess, roundTransition, gameEnd }
