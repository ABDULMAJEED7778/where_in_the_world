import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header bar for the online game screen.
/// Shows back button, round indicator, scores button, and settings button.
class OnlineGameHeader extends StatelessWidget {
  final int currentRound;
  final int totalRounds;
  final VoidCallback onBack;
  final VoidCallback onShowScores;
  final VoidCallback onShowSettings;

  const OnlineGameHeader({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.onBack,
    required this.onShowScores,
    required this.onShowSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'ROUND $currentRound/$totalRounds',
              textAlign: TextAlign.center,
              style: GoogleFonts.hanaleiFill(fontSize: 20, color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: onShowScores,
            icon: const Icon(Icons.leaderboard, color: Colors.white),
          ),
          IconButton(
            onPressed: onShowSettings,
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
