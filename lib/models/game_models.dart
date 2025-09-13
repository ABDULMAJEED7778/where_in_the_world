class Player {
  final String name;
  int score;
  int questionsAsked;
  int questionsRemaining;
  bool hasGuessed;

  Player({
    required this.name,
    this.score = 0,
    this.questionsAsked = 0,
    this.questionsRemaining = 2,
    this.hasGuessed = false,
  });

  void askQuestion() {
    if (questionsRemaining > 0) {
      questionsRemaining--;
      questionsAsked++;
    }
  }

  void resetForNewRound() {
    questionsRemaining = 2;
    hasGuessed = false;
  }

  void addScore(int points) {
    score += points;
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

  Landmark({
    required this.name,
    required this.country,
    required this.imagePath,
    required this.description,
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

enum GameMode { singlePlayer, multiplayer }

enum Difficulty { easy, moderate, difficult }

class GameState {
  final List<Player> players;
  final List<Question> questionsAsked;
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
    this.currentLandmark,
    this.currentPlayer,
    this.currentRound = 1,
    required this.settings,
    this.gameStarted = false,
    this.gameEnded = false,
    this.winner,
  });

  bool get isGameOver => gameEnded;

  GameState copyWith({
    List<Player>? players,
    List<Question>? questionsAsked,
    Landmark? currentLandmark,
    Player? currentPlayer,
    int? currentRound,
    GameSettings? settings,
    bool? gameStarted,
    bool? gameEnded,
    String? winner,
  }) {
    return GameState(
      players: players ?? this.players,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      currentLandmark: currentLandmark ?? this.currentLandmark,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      currentRound: currentRound ?? this.currentRound,
      settings: settings ?? this.settings,
      gameStarted: gameStarted ?? this.gameStarted,
      gameEnded: gameEnded ?? this.gameEnded,
      winner: winner ?? this.winner,
    );
  }
}
