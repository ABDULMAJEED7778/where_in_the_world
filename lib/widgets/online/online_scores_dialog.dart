import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/online_game_models.dart';

/// Glassmorphism leaderboard dialog showing player scores.
class OnlineScoresDialog extends StatelessWidget {
  final List<OnlinePlayer> players;

  const OnlineScoresDialog({super.key, required this.players});

  /// Convenience method to show this dialog.
  static void show(BuildContext context, List<OnlinePlayer> players) {
    showDialog(
      context: context,
      builder: (context) => OnlineScoresDialog(players: players),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<OnlinePlayer>.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 28.0);
    final nameFontSize = (screenWidth * 0.04).clamp(14.0, 18.0);
    final scoreFontSize = (screenWidth * 0.05).clamp(16.0, 22.0);
    final iconSize = (screenWidth * 0.07).clamp(24.0, 32.0);
    final tileVerticalPad = (screenHeight * 0.015).clamp(8.0, 16.0);
    final tileHorizontalPad = (screenWidth * 0.04).clamp(12.0, 20.0);
    final dialogPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final rankCircleSize = (screenWidth * 0.08).clamp(28.0, 36.0);
    final spacing = (screenHeight * 0.02).clamp(8.0, 32.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 450,
            maxHeight: screenHeight * 0.85,
          ),
          child: Container(
            padding: EdgeInsets.all(dialogPadding),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B69).withOpacity(0.85),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFFFFEA00).withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFFFFEA00).withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEA00).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFEA00),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: const Color(0xFFFFEA00),
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'LEADERBOARD',
                      style: GoogleFonts.hanaleiFill(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),

                // Scrollable Players List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sortedPlayers.length,
                    itemBuilder: (context, index) {
                      final player = sortedPlayers[index];
                      final isFirst = index == 0;
                      final isSecond = index == 1;
                      final isThird = index == 2;
                      final isTopThree = index < 3;

                      final Color rankColor = isFirst
                          ? const Color(0xFFFFD700)
                          : isSecond
                          ? const Color(0xFFC0C0C0)
                          : isThird
                          ? const Color(0xFFCD7F32)
                          : Colors.white70;

                      final String medalEmoji = isFirst
                          ? "🥇"
                          : isSecond
                          ? "🥈"
                          : isThird
                          ? "🥉"
                          : "";

                      return Container(
                        margin: EdgeInsets.only(bottom: tileVerticalPad * 0.75),
                        padding: EdgeInsets.symmetric(
                          horizontal: tileHorizontalPad,
                          vertical: tileVerticalPad,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              rankColor.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isTopThree
                                ? rankColor.withOpacity(0.8)
                                : Colors.white24,
                            width: isTopThree ? 2 : 1,
                          ),
                          boxShadow: isTopThree
                              ? [
                                  BoxShadow(
                                    color: rankColor.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Rank Circle
                            Container(
                              width: rankCircleSize,
                              height: rankCircleSize,
                              decoration: BoxDecoration(
                                color: rankColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: rankColor, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  isTopThree ? medalEmoji : '${index + 1}',
                                  style: TextStyle(
                                    color: rankColor,
                                    fontSize: nameFontSize * 0.85,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Player Name
                            Expanded(
                              child: Text(
                                player.nickname.toUpperCase(),
                                style: GoogleFonts.hanaleiFill(
                                  color: Colors.white,
                                  fontSize: nameFontSize,
                                  fontWeight: isTopThree
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Score
                            Text(
                              player.score.toString(),
                              style: GoogleFonts.hanaleiFill(
                                color: isTopThree ? rankColor : Colors.white70,
                                fontSize: scoreFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: spacing * 0.75),

                // Close Button
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEA00),
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: tileVerticalPad,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFFFEA00).withOpacity(0.5),
                  ),
                  child: Text(
                    'CLOSE',
                    style: GoogleFonts.hanaleiFill(
                      fontWeight: FontWeight.bold,
                      fontSize: nameFontSize * 0.9,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
