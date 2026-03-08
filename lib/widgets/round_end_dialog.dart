import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';

class RoundEndDialog extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onNextRound;
  final VoidCallback onViewScores;

  const RoundEndDialog({
    super.key,
    required this.gameState,
    required this.onNextRound,
    required this.onViewScores,
  });

  @override
  State<RoundEndDialog> createState() => _RoundEndDialogState();
}

class _RoundEndDialogState extends State<RoundEndDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final dialogWidth = (screenWidth * 0.9).clamp(300.0, 600.0);
    final isPhone = screenWidth < 600;

    // Dynamic values
    final padding = (screenWidth * 0.05).clamp(16.0, 32.0);
    final headerFontSize = (screenWidth * 0.06).clamp(20.0, 28.0);
    final answerFontSize = (screenWidth * 0.07).clamp(22.0, 32.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(14.0, 18.0);
    final buttonFontSize = (screenWidth * 0.035).clamp(14.0, 16.0);
    final spacing = (screenHeight * 0.02).clamp(10.0, 32.0);
    final buttonPadding = (screenHeight * 0.015).clamp(10.0, 14.0);

    final correctAnswer = widget.gameState.currentLandmark!.country;
    final isSinglePlayer =
        widget.gameState.settings.gameMode == GameMode.singlePlayer;

    // For single player, get the player's guess
    final currentPlayer = widget.gameState.players.first;
    final playerGuess = widget.gameState.playerGuesses[currentPlayer.id];
    final isCorrect =
        playerGuess != null &&
        playerGuess.toLowerCase() == correctAnswer.toLowerCase();

    // For party mode, get correct players and nearest guesser
    final correctPlayers = widget.gameState.players.where((player) {
      final guess = widget.gameState.playerGuesses[player.id];
      return guess != null &&
          guess.toLowerCase() == correctAnswer.toLowerCase();
    }).toList();

    Player? nearestGuesser;
    if (!isSinglePlayer && correctPlayers.isEmpty) {
      for (final player in widget.gameState.players) {
        if (player.score > 0) {
          nearestGuesser = player;
          break;
        }
      }
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Blurred background
            Opacity(
              opacity: _opacityAnimation.value * 0.7,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
            // Dialog Card
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    insetPadding: EdgeInsets.all(16),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: dialogWidth,
                        maxHeight: screenHeight * 0.85,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A34A3).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFFFEA00),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            spreadRadius: 10,
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFEA00).withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 20,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Header
                              Container(
                                padding: EdgeInsets.all(padding * 0.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEA00),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFFEA00,
                                      ).withOpacity(0.4),
                                      spreadRadius: 5,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '🏁 ROUND OVER! 🏁',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.hanaleiFill(
                                    textStyle: TextStyle(
                                      color: const Color(0xFF2D1B69),
                                      fontSize: headerFontSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: spacing),

                              // Correct Answer Section
                              Column(
                                children: [
                                  Text(
                                    'The Correct Answer Was:',
                                    style: GoogleFonts.hanaleiFill(
                                      textStyle: TextStyle(
                                        color: Colors.white70,
                                        fontSize: bodyFontSize,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacing * 0.4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: padding,
                                      vertical: padding * 0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFFEA00,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(0xFFFFEA00),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      correctAnswer.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.hanaleiFill(
                                        textStyle: TextStyle(
                                          color: const Color(0xFFFFEA00),
                                          fontSize: answerFontSize,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: spacing),
                              // Divider
                              Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFFFFEA00),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: spacing),

                              // ========== SINGLE PLAYER MODE ==========
                              if (isSinglePlayer) ...[
                                if (isCorrect) ...[
                                  // Correct guess celebration
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: padding,
                                      vertical: padding * 0.8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF74E67C,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF74E67C),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF74E67C,
                                          ).withOpacity(0.3),
                                          spreadRadius: 3,
                                          blurRadius: 15,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '🎉 CORRECT! 🎉',
                                          style: GoogleFonts.hanaleiFill(
                                            textStyle: TextStyle(
                                              color: const Color(0xFF74E67C),
                                              fontSize: bodyFontSize * 1.4,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: spacing * 0.5),
                                        Icon(
                                          Icons.check_circle,
                                          color: const Color(0xFF74E67C),
                                          size: headerFontSize * 2,
                                        ),
                                        SizedBox(height: spacing * 0.5),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF74E67C),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          child: Text(
                                            '+10 POINTS',
                                            style: GoogleFonts.hanaleiFill(
                                              textStyle: TextStyle(
                                                color: const Color(0xFF2D1B69),
                                                fontSize: bodyFontSize,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  // Incorrect guess feedback
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: padding,
                                      vertical: padding * 0.8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFE63C3D,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFE63C3D),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          playerGuess != null
                                              ? '❌ NOT QUITE'
                                              : '⏰ TIME UP',
                                          style: GoogleFonts.hanaleiFill(
                                            textStyle: TextStyle(
                                              color: const Color(0xFFE63C3D),
                                              fontSize: bodyFontSize * 1.3,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                        ),
                                        if (playerGuess != null) ...[
                                          SizedBox(height: spacing * 0.5),
                                          Text(
                                            'Your Guess:',
                                            style: GoogleFonts.hanaleiFill(
                                              textStyle: TextStyle(
                                                color: Colors.white60,
                                                fontSize: bodyFontSize * 0.85,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: spacing * 0.3),
                                          Text(
                                            playerGuess.toUpperCase(),
                                            style: GoogleFonts.hanaleiFill(
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: bodyFontSize * 1.1,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                        SizedBox(height: spacing * 0.5),
                                        Text(
                                          'Better luck next round!',
                                          style: GoogleFonts.hanaleiFill(
                                            textStyle: TextStyle(
                                              color: Colors.white70,
                                              fontSize: bodyFontSize * 0.9,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                SizedBox(height: spacing),

                                // Single Player: Only Next button (no scores button)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: widget.onNextRound,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF74E67C),
                                      padding: EdgeInsets.symmetric(
                                        vertical: buttonPadding * 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 8,
                                    ),
                                    child: Text(
                                      widget.gameState.currentRound <
                                              widget
                                                  .gameState
                                                  .settings
                                                  .numberOfRounds
                                          ? '▶ NEXT ROUND'
                                          : '✓ FINISH GAME',
                                      style: GoogleFonts.hanaleiFill(
                                        textStyle: TextStyle(
                                          color: const Color(0xFF2D1B69),
                                          fontSize: buttonFontSize * 1.1,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                              // ========== PARTY MODE ==========
                              else ...[
                                if (correctPlayers.isNotEmpty) ...[
                                  Text(
                                    '🎉 ROUND WINNER! 🎉',
                                    style: GoogleFonts.hanaleiFill(
                                      textStyle: TextStyle(
                                        color: const Color(0xFF74E67C),
                                        fontSize: bodyFontSize * 1.3,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacing * 0.5),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: padding,
                                      vertical: padding * 0.6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF74E67C,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(0xFF74E67C),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF74E67C,
                                          ).withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          color: const Color(0xFFFFEA00),
                                          size: headerFontSize * 1.5,
                                        ),
                                        SizedBox(height: spacing * 0.3),
                                        Text(
                                          correctPlayers.first.name,
                                          style: GoogleFonts.hanaleiFill(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: bodyFontSize * 1.2,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: spacing * 0.4),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF74E67C),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            '+10 POINTS',
                                            style: GoogleFonts.hanaleiFill(
                                              textStyle: TextStyle(
                                                color: const Color(0xFF2D1B69),
                                                fontSize: bodyFontSize * 0.9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (nearestGuesser != null) ...[
                                  Text(
                                    '📍 Nearest Guess:',
                                    style: GoogleFonts.hanaleiFill(
                                      textStyle: TextStyle(
                                        color: const Color(0xFF74E67C),
                                        fontSize: bodyFontSize * 1.2,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacing * 0.5),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: padding,
                                      vertical: padding * 0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF74E67C,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF74E67C),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          nearestGuesser.name,
                                          style: GoogleFonts.hanaleiFill(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: bodyFontSize,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: spacing * 0.3),
                                        Text(
                                          'Guessed: ${widget.gameState.playerGuesses[nearestGuesser.id]}',
                                          style: GoogleFonts.hanaleiFill(
                                            textStyle: TextStyle(
                                              color: Colors.white70,
                                              fontSize: bodyFontSize * 0.8,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: spacing * 0.3),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF74E67C),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '+5 POINTS',
                                            style: GoogleFonts.hanaleiFill(
                                              textStyle: TextStyle(
                                                color: const Color(0xFF2D1B69),
                                                fontSize: bodyFontSize * 0.8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    'No Correct Guesses',
                                    style: GoogleFonts.hanaleiFill(
                                      textStyle: TextStyle(
                                        color: Colors.white70,
                                        fontSize: bodyFontSize,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],

                                SizedBox(height: spacing),

                                // Party Mode: Scores + Next buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: widget.onViewScores,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFFEA00,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: buttonPadding,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 8,
                                        ),
                                        child: Text(
                                          isPhone ? 'SCORES' : '🏆 SCORES',
                                          style: GoogleFonts.hanaleiFill(
                                            textStyle: TextStyle(
                                              color: const Color(0xFF2D1B69),
                                              fontSize: buttonFontSize,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: widget.onNextRound,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF74E67C,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: buttonPadding,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 8,
                                        ),
                                        child: Text(
                                          widget.gameState.currentRound <
                                                  widget
                                                      .gameState
                                                      .settings
                                                      .numberOfRounds
                                              ? (isPhone ? 'NEXT' : '▶ NEXT')
                                              : (isPhone
                                                    ? 'FINISH'
                                                    : '✓ FINISH'),
                                          style: GoogleFonts.hanaleiFill(
                                            textStyle: TextStyle(
                                              color: const Color(0xFF2D1B69),
                                              fontSize: buttonFontSize,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
