import 'package:flutter/material.dart';
import '../models/game_models.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState(
    players: [],
    questionsAsked: [],
    settings: GameSettings(
      gameMode: GameMode.multiplayer,
      difficulty: Difficulty.easy,
      numberOfRounds: 6,
      questionsPerPlayer: 2,
    ),
  );

  GameState get gameState => _gameState;

  // Sample landmarks data - in a real app, this would come from an API or database
  final List<Landmark> _landmarks = [
    Landmark(
      name: "Mount Kilimanjaro",
      country: "Tanzania",
      imagePath: "assets/landmarks/kilimanjaro.jpg",
      description: "Africa's highest mountain with snow-capped peak",
    ),
    Landmark(
      name: "Eiffel Tower",
      country: "France",
      imagePath: "assets/landmarks/eiffel_tower.jpg",
      description: "Iconic iron lattice tower in Paris",
    ),
    Landmark(
      name: "Great Wall of China",
      country: "China",
      imagePath: "assets/landmarks/great_wall.jpg",
      description: "Ancient fortification system in northern China",
    ),
    Landmark(
      name: "Machu Picchu",
      country: "Peru",
      imagePath: "assets/landmarks/machu_picchu.jpg",
      description: "15th-century Inca citadel in the Andes",
    ),
    Landmark(
      name: "Taj Mahal",
      country: "India",
      imagePath: "assets/landmarks/taj_mahal.jpg",
      description: "White marble mausoleum in Agra",
    ),
  ];

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

  void startGame() {
    if (_gameState.players.length >= 2) {
      _gameState = _gameState.copyWith(
        gameStarted: true,
        currentPlayer: _gameState.players.first,
        currentLandmark: _getRandomLandmark(),
      );
      notifyListeners();
    }
  }

  void askQuestion(String questionText, bool answer) {
    if (_gameState.currentPlayer != null &&
        _gameState.currentPlayer!.questionsRemaining > 0) {
      final question = Question(
        text: questionText,
        answer: answer,
        askedBy: _gameState.currentPlayer!.name,
      );

      _gameState.currentPlayer!.askQuestion();

      _gameState = _gameState.copyWith(
        questionsAsked: [..._gameState.questionsAsked, question],
      );
      notifyListeners();
    }
  }

  void makeGuess(String country) {
    if (_gameState.currentPlayer != null &&
        !_gameState.currentPlayer!.hasGuessed) {
      _gameState.currentPlayer!.hasGuessed = true;

      // Check if guess is correct
      if (_gameState.currentLandmark != null &&
          country.toLowerCase() ==
              _gameState.currentLandmark!.country.toLowerCase()) {
        _gameState.currentPlayer!.addScore(10);
        _nextRound();
      } else {
        _nextPlayer();
      }
      notifyListeners();
    }
  }

  void _nextPlayer() {
    final currentIndex = _gameState.players.indexOf(_gameState.currentPlayer!);
    final nextIndex = (currentIndex + 1) % _gameState.players.length;
    _gameState = _gameState.copyWith(
      currentPlayer: _gameState.players[nextIndex],
    );
  }

  void _nextRound() {
    if (_gameState.currentRound < _gameState.settings.numberOfRounds) {
      // Reset all players for new round
      for (var player in _gameState.players) {
        player.resetForNewRound();
      }

      _gameState = _gameState.copyWith(
        currentRound: _gameState.currentRound + 1,
        currentPlayer: _gameState.players.first,
        currentLandmark: _getRandomLandmark(),
        questionsAsked: [],
      );
    } else {
      _endGame();
    }
  }

  void _endGame() {
    final winner = _gameState.players.reduce(
      (a, b) => a.score > b.score ? a : b,
    );
    _gameState = _gameState.copyWith(gameEnded: true, winner: winner.name);
  }

  Landmark _getRandomLandmark() {
    _landmarks.shuffle();
    return _landmarks.first;
  }

  void resetGame() {
    _gameState = GameState(
      players: [],
      questionsAsked: [],
      settings: GameSettings(
        gameMode: GameMode.multiplayer,
        difficulty: Difficulty.easy,
        numberOfRounds: 6,
        questionsPerPlayer: 2,
      ),
    );
    notifyListeners();
  }
}

