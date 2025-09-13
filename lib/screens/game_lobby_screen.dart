import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import 'main_game_screen.dart';

class GameLobbyScreen extends StatefulWidget {
  const GameLobbyScreen({super.key});

  @override
  State<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  GameMode _selectedGameMode = GameMode.multiplayer;
  Difficulty _selectedDifficulty = Difficulty.easy;
  int _numberOfRounds = 6;
  int _questionsPerPlayer = 2;

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69), // Primary background
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 540),
            decoration: BoxDecoration(
              color: const Color(
                0xFF2D1B69,
              ).withOpacity(0.8), // Primary with opacity
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 20),
                  const Text(
                    'CHOOSE YOUR GAME SETTINGS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildGameModeSection(),
                  const SizedBox(height: 20),
                  _buildDifficultySection(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildRoundsSection(),
                      const SizedBox(width: 40),
                      _buildQuestionsSection(),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildPlayerList(),
                  ),
                  const SizedBox(height: 0),
                  _buildAddPlayerSection(),
                  const SizedBox(height: 30),
                  _buildRulesSection(),
                  const SizedBox(height: 30),
                  _buildPlayButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to the original design if image fails to load
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D1B69), // Primary
                    Color(0xFF74E67C), // Green
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'WHERE',
                    style: GoogleFonts.hanaleiFill(
                      color: const Color(0xFFF3D42B), // Yellow
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'IN THE',
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'WORLD?',
                    style: GoogleFonts.hanaleiFill(
                      color: const Color(0xFFF3D42B), // Yellow
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameModeSection() {
    return Row(
      children: [
        Text(
          'GAME MODE:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(width: 20.0),
        Expanded(
          child: _buildModeButton(
            'MULTIPLAYER',
            GameMode.multiplayer,
            _selectedGameMode == GameMode.multiplayer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildModeButton(
            'SINGLE PLAYER',
            GameMode.singlePlayer,
            _selectedGameMode == GameMode.singlePlayer,
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton(String text, GameMode mode, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGameMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF74E67C) : const Color(0xFFE63C3D),
          borderRadius: BorderRadius.circular(40),
          border: BoxBorder.all(color: Colors.black, width: 1.0),
        ),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            // Black stroke
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = Colors.black,
              ),
            ),
            // White fill
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Row(
      children: [
        const Text(
          'DIFFICULTY:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 20.0),
        Expanded(
          child: _buildDifficultyButton(
            'EASY',
            Difficulty.easy,
            _selectedDifficulty == Difficulty.easy,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDifficultyButton(
            'MODERATE',
            Difficulty.moderate,
            _selectedDifficulty == Difficulty.moderate,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDifficultyButton(
            'DIFFICULT',
            Difficulty.difficult,
            _selectedDifficulty == Difficulty.difficult,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyButton(
    String text,
    Difficulty difficulty,
    bool isSelected,
  ) {
    Color colorBn;
    if (isSelected) {
      colorBn = const Color(0xFF74E67C); // Green
    } else if (difficulty == Difficulty.moderate) {
      colorBn = const Color(0xFFF3D42B); // Yellow
    } else {
      colorBn = const Color(0xFFE63C3D); // Red
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = difficulty),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorBn, width: 2),
          ),
          onPressed: () {},
          child: Stack(
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.black,
                ),
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'NO. OF ROUNDS:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(width: 16.0),
        Row(
          children: [
            _buildNumberField(_numberOfRounds),
            Column(
              children: [
                _buildArrowButton(Icons.keyboard_arrow_up, () {
                  setState(() => _numberOfRounds++);
                }),
                _buildArrowButton(Icons.keyboard_arrow_down, () {
                  if (_numberOfRounds > 1) {
                    setState(() => _numberOfRounds--);
                  }
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 152,
          child: const Text(
            'NO. OF QUESTIONS FOR EACH PLAYER:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Row(
          children: [
            _buildNumberField(_questionsPerPlayer),
            Column(
              children: [
                _buildArrowButton(Icons.keyboard_arrow_up, () {
                  setState(() => _questionsPerPlayer++);
                }),
                _buildArrowButton(Icons.keyboard_arrow_down, () {
                  if (_questionsPerPlayer > 1) {
                    setState(() => _questionsPerPlayer--);
                  }
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField(int value) {
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          bottomLeft: Radius.circular(12.0),
        ),
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: icon == Icons.keyboard_arrow_down
              ? BorderRadius.only(bottomRight: Radius.circular(12.0))
              : BorderRadius.only(topRight: Radius.circular(12.0)),
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildPlayerList() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PLAYERS:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 10),
            ...gameProvider.gameState.players.map(
              (player) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        player.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () => gameProvider.removePlayer(player.name),
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddPlayerSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _playerNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter player name',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            if (_playerNameController.text.isNotEmpty) {
              context.read<GameProvider>().addPlayer(
                _playerNameController.text,
              );
              _playerNameController.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF74E67C), // Green
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Stack(
            children: [
              Text(
                "ADD",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.black,
                ),
              ),
              const Text(
                'ADD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_book, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'RULES:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• PLAYER WHO ASKED THE LAST QUESTION HAS THE PRIORITY TO GUESS.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 4),
            Text(
              '• CANCELLATION OF A GUESS AFTER PRESSING THE GUESS BUTTON IS NOT ALLOWED.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 4),
            Text(
              '• PLAYERS ARE ALLOWED TO DIRECTLY GUESS AT THEIR TURN POINT IN THE GAME.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 4),
            Text(
              '• IN CASE NO PLAYER GUESSES THE RIGHT COUNTRY, THE PLAYER WITH A GUESS OF THE NEAREST COUNTRY TO THE CAPITAL IS GIVEN ONE POINT.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            gradient: const SweepGradient(
              colors: [
                Color(0xFFE63C3D),
                Color(0xFFEB7A36),
                Color(0xFFF3D42B),
                Color(0xFFEB7A36),
                Color(0xFFE63C3D),
              ],
              stops: [0.31, 0.52, 0.64, 0.9, 0.99],
              startAngle: 0.9,
              tileMode: TileMode.mirror,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: ElevatedButton(
            onPressed: gameProvider.gameState.players.length >= 2
                ? () {
                    gameProvider.updateSettings(
                      GameSettings(
                        gameMode: _selectedGameMode,
                        difficulty: _selectedDifficulty,
                        numberOfRounds: _numberOfRounds,
                        questionsPerPlayer: _questionsPerPlayer,
                      ),
                    );
                    gameProvider.startGame();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainGameScreen(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Stack(
              children: [
                Text(
                  "PLAY!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = Colors.black,
                  ),
                ),

                const Text(
                  'PLAY!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
