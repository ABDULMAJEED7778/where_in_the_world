import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';

class LeaderboardDialog extends StatelessWidget {
  final List<Player> players;
  final bool showAfterRound;

  const LeaderboardDialog({
    super.key,
    required this.players,
    this.showAfterRound = false,
  });

  @override
  Widget build(BuildContext context) {
    // Sort players by score in descending order
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
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
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFFFEA00),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'LEADERBOARD',
                    style: GoogleFonts.hanaleiFill(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Scrollable List
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
                        ? const Color(0xFFFFD700) // Gold
                        : isSecond
                        ? const Color(0xFFC0C0C0) // Silver
                        : isThird
                        ? const Color(0xFFCD7F32) // Bronze
                        : Colors.white70;

                    final String medalEmoji = isFirst
                        ? "🥇"
                        : isSecond
                        ? "🥈"
                        : isThird
                        ? "🥉"
                        : "";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
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
                            width: 36,
                            height: 36,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Player Name
                          Expanded(
                            child: Text(
                              player.name.toUpperCase(),
                              style: GoogleFonts.hanaleiFill(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: isTopThree
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          // Score
                          Text(
                            player.score.toString(),
                            style: GoogleFonts.hanaleiFill(
                              color: isTopThree ? rankColor : Colors.white70,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEA00),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
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
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
