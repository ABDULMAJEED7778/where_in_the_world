import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../turn_timer_widget.dart';

/// Indicator showing whose turn it is, or that all questions are used.
class OnlineTurnIndicator extends StatelessWidget {
  final String? currentPlayerName;
  final bool isMyTurn;
  final bool allQuestionsUsed;
  final int timeRemaining;
  final int totalTime;
  final bool isImageLoaded;
  final int questionsRemaining;
  final bool isTimerEnabled;

  const OnlineTurnIndicator({
    super.key,
    required this.currentPlayerName,
    required this.isMyTurn,
    required this.allQuestionsUsed,
    required this.questionsRemaining,
    this.timeRemaining = 0,
    this.totalTime = 60,
    this.isImageLoaded = true,
    this.isTimerEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (allQuestionsUsed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF3D00).withOpacity(0.3),
              const Color(0xFFFF3D00).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF3D00), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb, color: Color(0xFFFFB300)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Text(
                    "NO QUESTIONS LEFT!",
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Time to make your guess",
                    style: GoogleFonts.hanaleiFill(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMyTurn
            ? const Color(0xFF00E676).withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isMyTurn
            ? Border.all(color: const Color(0xFF00E676), width: 2)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isMyTurn
                  ? const Color(0xFF00E676).withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 14,
                  color: isMyTurn ? const Color(0xFF00E676) : Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  '$questionsRemaining',
                  style: GoogleFonts.hanaleiFill(
                    color: isMyTurn ? const Color(0xFF00E676) : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            isMyTurn ? Icons.person : Icons.hourglass_top,
            color: isMyTurn ? const Color(0xFF00E676) : Colors.white54,
          ),
          const SizedBox(width: 8),
          Text(
            isMyTurn
                ? "IT'S YOUR TURN!"
                : "${currentPlayerName ?? 'Someone'}'s turn",
            style: GoogleFonts.hanaleiFill(
              color: isMyTurn ? const Color(0xFF00E676) : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          TurnTimerWidget(
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            size: 28,
            isPaused: !isImageLoaded,
            isEnabled: isTimerEnabled,
          ),
        ],
      ),
    );
  }
}
