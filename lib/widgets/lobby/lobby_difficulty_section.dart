import 'package:flutter/material.dart';
import '../../models/game_models.dart';
import '../../services/audio_service.dart';
import '../../utils/responsive.dart';

/// Difficulty selector with EASY / MODERATE / DIFFICULT buttons.
/// Responsive layout: column on phones, row on larger screens.
class LobbyDifficultySection extends StatelessWidget {
  final Difficulty selectedDifficulty;
  final ValueChanged<Difficulty> onDifficultyChanged;

  const LobbyDifficultySection({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labelFontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 17,
      desktop: 18,
    );

    final buttonFontSize = Responsive.value<double>(
      context,
      phone: 11,
      tablet: 13,
      laptop: 14,
      desktop: 15,
    );

    final buttons = [
      Expanded(
        child: _buildDifficultyButton(
          context,
          'EASY',
          Difficulty.easy,
          selectedDifficulty == Difficulty.easy,
          buttonFontSize,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildDifficultyButton(
          context,
          'MODERATE',
          Difficulty.moderate,
          selectedDifficulty == Difficulty.moderate,
          buttonFontSize,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildDifficultyButton(
          context,
          'DIFFICULT',
          Difficulty.difficult,
          selectedDifficulty == Difficulty.difficult,
          buttonFontSize,
        ),
      ),
    ];

    if (Responsive.isPhone(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIFFICULTY:',
            style: TextStyle(
              color: Colors.white,
              fontSize: labelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(children: buttons),
        ],
      );
    }

    return Row(
      children: [
        Text(
          'DIFFICULTY:',
          style: TextStyle(
            color: Colors.white,
            fontSize: labelFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 20),
        ...buttons,
      ],
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String text,
    Difficulty difficulty,
    bool isSelected,
    double fontSize,
  ) {
    Color baseColor;
    switch (difficulty) {
      case Difficulty.easy:
        baseColor = const Color(0xFF74E67C);
        break;
      case Difficulty.moderate:
        baseColor = const Color(0xFFF3D42B);
        break;
      case Difficulty.difficult:
        baseColor = const Color(0xFFE63C3D);
        break;
    }

    return GestureDetector(
      onTap: () {
        AudioService().playSecondaryButtonClick();
        onDifficultyChanged(difficulty);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: Responsive.value<double>(
            context,
            phone: 10,
            tablet: 12,
            laptop: 14,
            desktop: 14,
          ),
          horizontal: Responsive.value<double>(
            context,
            phone: 6,
            tablet: 8,
            laptop: 10,
            desktop: 10,
          ),
        ),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.grey.shade400.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1.5),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    baseColor.withOpacity(0.9),
                    baseColor.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.7),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = Colors.black,
              ),
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
            if (isSelected)
              Positioned(
                right: 2,
                top: 2,
                child: Icon(
                  Icons.check_circle,
                  size: fontSize * 1.1,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
