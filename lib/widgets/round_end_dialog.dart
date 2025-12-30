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
    final correctAnswer = widget.gameState.currentLandmark!.country;
    final correctPlayers = widget.gameState.players.where((player) {
      final guess = widget.gameState.playerGuesses[player.id];
      return guess != null &&
          guess.toLowerCase() == correctAnswer.toLowerCase();
    }).toList();

    Player? nearestGuesser;
    if (correctPlayers.isEmpty) {
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
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 600,
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.all(16),
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
                                    textStyle: const TextStyle(
                                      color: Color(0xFF2D1B69),
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Correct Answer Section
                              Column(
                                children: [
                                  Text(
                                    'The Correct Answer Was:',
                                    style: GoogleFonts.hanaleiFill(
                                      textStyle: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
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
                                      style: GoogleFonts.hanaleiFill(
                                        textStyle: const TextStyle(
                                          color: Color(0xFFFFEA00),
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),
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
                              const SizedBox(height: 32),

                              // Guesses Section
                              if (correctPlayers.isNotEmpty) ...[
                                Text(
                                  '✅ Correct Guesses:',
                                  style: GoogleFonts.hanaleiFill(
                                    textStyle: const TextStyle(
                                      color: Color(0xFF74E67C),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...correctPlayers.map(
                                  (player) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            player.name,
                                            style: GoogleFonts.hanaleiFill(
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF74E67C),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '+10',
                                              style: GoogleFonts.hanaleiFill(
                                                textStyle: const TextStyle(
                                                  color: Color(0xFF2D1B69),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ] else if (nearestGuesser != null) ...[
                                Text(
                                  '📍 Nearest Guess:',
                                  style: GoogleFonts.hanaleiFill(
                                    textStyle: const TextStyle(
                                      color: Color(0xFF74E67C),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
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
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Guessed: ${widget.gameState.playerGuesses[nearestGuesser.id]}',
                                        style: GoogleFonts.hanaleiFill(
                                          textStyle: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF74E67C),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '+5',
                                          style: GoogleFonts.hanaleiFill(
                                            textStyle: const TextStyle(
                                              color: Color(0xFF2D1B69),
                                              fontSize: 14,
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
                                    textStyle: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 32),

                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: widget.onViewScores,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFFEA00,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 8,
                                      ),
                                      child: Text(
                                        '🏆 SCORES',
                                        style: GoogleFonts.hanaleiFill(
                                          textStyle: const TextStyle(
                                            color: Color(0xFF2D1B69),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: widget.onNextRound,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF74E67C,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
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
                                            ? '▶ NEXT'
                                            : '✓ FINISH',
                                        style: GoogleFonts.hanaleiFill(
                                          textStyle: const TextStyle(
                                            color: Color(0xFF2D1B69),
                                            fontSize: 16,
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
