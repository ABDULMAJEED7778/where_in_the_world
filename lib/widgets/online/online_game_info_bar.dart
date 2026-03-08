import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Info bar showing difficulty, questions per turn, and players remaining.
class OnlineGameInfoBar extends StatelessWidget {
  final int difficulty;
  final int questionsPerTurn;
  final int playersRemaining;
  final int totalPlayers;

  const OnlineGameInfoBar({
    super.key,
    required this.difficulty,
    required this.questionsPerTurn,
    required this.playersRemaining,
    required this.totalPlayers,
  });

  @override
  Widget build(BuildContext context) {
    Color difficultyColor;
    String difficultyText;
    switch (difficulty) {
      case 1:
        difficultyColor = const Color(0xFF74E67C);
        difficultyText = 'EASY';
        break;
      case 2:
        difficultyColor = const Color(0xFFF3D42B);
        difficultyText = 'MODERATE';
        break;
      case 3:
        difficultyColor = const Color(0xFFE63C3D);
        difficultyText = 'HARD';
        break;
      default:
        difficultyColor = const Color(0xFF74E67C);
        difficultyText = 'EASY';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoBadge(
            icon: Icons.speed,
            label: difficultyText,
            color: difficultyColor,
          ),
          Container(height: 30, width: 1, color: Colors.white.withOpacity(0.2)),
          _buildInfoBadge(
            icon: Icons.help_outline,
            label: '$questionsPerTurn Q/TURN',
            color: const Color(0xFFFFEA00),
          ),
          Container(height: 30, width: 1, color: Colors.white.withOpacity(0.2)),
          _buildInfoBadge(
            icon: Icons.people,
            label: '$playersRemaining/$totalPlayers',
            color: const Color(0xFF5BC0EB),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.hanaleiFill(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
