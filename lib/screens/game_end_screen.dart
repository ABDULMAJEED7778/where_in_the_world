import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../services/audio_service.dart';
import '../utils/responsive.dart';
import '../widgets/animated_background.dart';
import 'game_lobby_screen.dart';

/// A premium game end screen that displays the winner, final standings,
/// game statistics, and options to play again or return to the main menu.
class GameEndScreen extends StatefulWidget {
  final GameState gameState;

  const GameEndScreen({Key? key, required this.gameState}) : super(key: key);

  @override
  State<GameEndScreen> createState() => _GameEndScreenState();
}

class _GameEndScreenState extends State<GameEndScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti controller for celebration effect
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    // Animation controller for entrance animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _animationController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPhone = Responsive.isPhone(context);

    // Responsive values
    final containerMaxWidth = Responsive.value<double>(
      context,
      phone: screenWidth * 0.92,
      tablet: 500,
      laptop: 440,
      desktop: 600,
    );

    final containerPadding = Responsive.value<double>(
      context,
      phone: 20,
      tablet: 24,
      laptop: 14,
      desktop: 32,
    );

    final titleFontSize = Responsive.value<double>(
      context,
      phone: 28,
      tablet: 32,
      laptop: 24,
      desktop: 38,
    );

    final trophySize = Responsive.value<double>(
      context,
      phone: 80,
      tablet: 90,
      laptop: 50,
      desktop: 100,
    );

    // Sort players by score (highest first)
    final sortedPlayers = List<Player>.from(widget.gameState.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    final winner = sortedPlayers.isNotEmpty ? sortedPlayers.first : null;
    final isSinglePlayer =
        widget.gameState.settings.gameMode == GameMode.singlePlayer;

    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69),
      body: Stack(
        children: [
          // Animated background
          const AnimatedBackground(),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFFFFD700), // Gold
                Color(0xFFF3D42B), // Yellow
                Color(0xFF74E67C), // Green
                Color(0xFFFF6B6B), // Red
                Color(0xFF4ECDC4), // Teal
                Color(0xFFAB47BC), // Purple
              ],
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 16 : 12,
                  vertical: isPhone ? 16 : 8,
                ),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final isLaptop = Responsive.isLaptop(context);
                    final sectionSpacing = isLaptop
                        ? 6.0
                        : containerPadding * 0.6;

                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          width: containerMaxWidth,
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.9,
                          ),
                          padding: EdgeInsets.all(containerPadding),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1A0F3D).withOpacity(0.95),
                                const Color(0xFF2D1B69).withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Trophy icon with glow effect
                                _buildTrophySection(trophySize),

                                SizedBox(height: sectionSpacing),

                                // Game Over title
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700),
                                          Color(0xFFFFA500),
                                          Color(0xFFFFD700),
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    isSinglePlayer
                                        ? 'GAME COMPLETE!'
                                        : 'GAME OVER!',
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),

                                SizedBox(height: sectionSpacing * 0.5),

                                // Winner announcement or score for single player
                                _buildWinnerSection(winner, isSinglePlayer),

                                SizedBox(height: sectionSpacing),

                                // Game statistics
                                _buildStatisticsSection(),

                                // Leaderboard (only for multiplayer)
                                if (!isSinglePlayer &&
                                    sortedPlayers.length > 1) ...[
                                  SizedBox(height: sectionSpacing),
                                  _buildLeaderboard(sortedPlayers),
                                ],

                                SizedBox(height: sectionSpacing),

                                // Action buttons
                                _buildActionButtons(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophySection(double size) {
    return Container(
      width: size * 1.3,
      height: size * 1.3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.3),
            const Color(0xFFFFD700).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.emoji_events_rounded,
          size: size,
          color: const Color(0xFFFFD700),
        ),
      ),
    );
  }

  Widget _buildWinnerSection(Player? winner, bool isSinglePlayer) {
    final fontSize = Responsive.value<double>(
      context,
      phone: 20,
      tablet: 24,
      laptop: 26,
      desktop: 28,
    );

    if (isSinglePlayer) {
      return Column(
        children: [
          Text(
            'Your Score',
            style: TextStyle(color: Colors.white70, fontSize: fontSize * 0.8),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${winner?.score ?? 0}',
                style: TextStyle(
                  color: const Color(0xFFFFD700),
                  fontSize: fontSize * 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'points',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: fontSize * 0.7,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '🎉 WINNER 🎉',
            style: TextStyle(
              color: const Color(0xFFFFD700),
              fontSize: fontSize * 0.6,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          winner?.name ?? 'Unknown',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${winner?.score ?? 0} points',
          style: TextStyle(
            color: const Color(0xFFFFD700),
            fontSize: fontSize * 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    final gameState = widget.gameState;
    final statFontSize = Responsive.value<double>(
      context,
      phone: 12,
      tablet: 14,
      laptop: 15,
      desktop: 16,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.flag_rounded,
            value: '${gameState.currentRound}',
            label: 'Rounds',
            fontSize: statFontSize,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.chat_bubble_outline_rounded,
            value: '${gameState.questionsAsked.length}',
            label: 'Questions',
            fontSize: statFontSize,
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.people_outline_rounded,
            value: '${gameState.players.length}',
            label: 'Players',
            fontSize: statFontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required double fontSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF74E67C), size: fontSize * 1.5),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize * 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white60, fontSize: fontSize * 0.85),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildLeaderboard(List<Player> players) {
    final headerFontSize = Responsive.value<double>(
      context,
      phone: 16,
      tablet: 18,
      laptop: 19,
      desktop: 20,
    );
    final isLaptop = Responsive.isLaptop(context);
    final headerSpacing = isLaptop ? 8.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'FINAL STANDINGS',
          style: TextStyle(
            color: Colors.white70,
            fontSize: headerFontSize * 0.75,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: headerSpacing),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: players.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final player = entry.value;
            return _buildLeaderboardRow(rank, player);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(int rank, Player player) {
    final isWinner = rank == 1;
    final Color rankColor;
    final IconData? rankIcon;

    final isLaptop = Responsive.isLaptop(context);
    final rowPadding = isLaptop ? 10.0 : 12.0;
    final rowMargin = isLaptop ? 6.0 : 8.0;
    final fontSize = isLaptop ? 14.0 : 16.0;
    final iconSize = isLaptop ? 20.0 : 24.0;

    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Gold
        rankIcon = Icons.emoji_events_rounded;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Silver
        rankIcon = Icons.emoji_events_rounded;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Bronze
        rankIcon = Icons.emoji_events_rounded;
        break;
      default:
        rankColor = Colors.white60;
        rankIcon = null;
    }

    return Container(
      margin: EdgeInsets.only(bottom: rowMargin),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: rowPadding),
      decoration: BoxDecoration(
        gradient: isWinner
            ? LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.2),
                  const Color(0xFFFFD700).withOpacity(0.05),
                ],
              )
            : null,
        color: isWinner ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: isWinner
            ? Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: iconSize + 8,
            child: rankIcon != null
                ? Icon(rankIcon, color: rankColor, size: iconSize)
                : Text(
                    '$rank',
                    style: TextStyle(
                      color: rankColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          // Player name
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                color: isWinner ? Colors.white : Colors.white70,
                fontSize: fontSize,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          // Score
          Text(
            '${player.score}',
            style: TextStyle(
              color: rankColor,
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'pts',
            style: TextStyle(color: Colors.white38, fontSize: fontSize * 0.75),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isLaptop = Responsive.isLaptop(context);

    final buttonHeight = Responsive.value<double>(
      context,
      phone: 50,
      tablet: 50,
      laptop: 38,
      desktop: 54,
    );

    final buttonFontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 13,
      desktop: 18,
    );

    // Play Again button
    Widget playAgainButton = SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          AudioService().playButtonClick();

          // Capture current settings and players before resetting
          final currentSettings = context
              .read<GameProvider>()
              .gameState
              .settings;
          final currentPlayers = context.read<GameProvider>().gameState.players;

          context.read<GameProvider>().resetGame();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => GameLobbyScreen(
                gameMode: currentSettings.gameMode,
                initialSettings: currentSettings,
                initialPlayers: currentPlayers,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF74E67C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
          elevation: 4,
          padding: EdgeInsets.symmetric(horizontal: isLaptop ? 12 : 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isLaptop ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              Icons.replay_rounded,
              color: Colors.white,
              size: buttonFontSize * 1.2,
            ),
            SizedBox(width: isLaptop ? 6 : 10),
            Text(
              (isLaptop || Responsive.isPhone(context)) ? 'PLAY' : 'PLAY AGAIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: buttonFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    // Main Menu button
    Widget mainMenuButton = SizedBox(
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: () {
          AudioService().playSecondaryButtonClick();
          AudioService().stopMusic();
          context.read<GameProvider>().resetGame();
          Navigator.of(context).pushReplacementNamed('/');
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.5), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
          padding: EdgeInsets.symmetric(horizontal: isLaptop ? 12 : 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isLaptop ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              Icons.home_rounded,
              color: Colors.white70,
              size: buttonFontSize * 1.2,
            ),
            SizedBox(width: isLaptop ? 6 : 10),
            Text(
              (isLaptop || Responsive.isPhone(context)) ? 'MENU' : 'MAIN MENU',
              style: TextStyle(
                color: Colors.white70,
                fontSize: buttonFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    // Share Results button
    Widget shareResultsButton = TextButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share feature coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      icon: Icon(
        Icons.share_rounded,
        color: Colors.white38,
        size: buttonFontSize,
      ),
      label: Text(
        'Share Results',
        style: TextStyle(
          color: Colors.white38,
          fontSize: buttonFontSize * 0.85,
        ),
      ),
    );

    // Laptop or Phone: side-by-side buttons with Share below
    if (isLaptop || Responsive.isPhone(context)) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: playAgainButton),
              const SizedBox(width: 10),
              Expanded(child: mainMenuButton),
            ],
          ),
          const SizedBox(height: 8),
          shareResultsButton,
        ],
      );
    }

    // Other screens (Tablets?): stacked buttons
    return Column(
      children: [
        SizedBox(width: double.infinity, child: playAgainButton),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: mainMenuButton),
        const SizedBox(height: 12),
        shareResultsButton,
      ],
    );
  }
}
