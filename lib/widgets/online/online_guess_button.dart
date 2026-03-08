import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Red guess button, or "guessed incorrectly" state.
class OnlineGuessButton extends StatelessWidget {
  final bool hasGuessed;
  final VoidCallback onGuess;

  const OnlineGuessButton({
    super.key,
    required this.hasGuessed,
    required this.onGuess,
  });

  @override
  Widget build(BuildContext context) {
    if (hasGuessed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.close, color: Colors.red, size: 24),
            const SizedBox(height: 8),
            Text(
              'You guessed incorrectly',
              style: GoogleFonts.hanaleiFill(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Wait for round end',
              style: GoogleFonts.hanaleiFill(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onGuess,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE63C3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 4,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'GUESS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = Colors.black,
              ),
            ),
            const Text(
              'GUESS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
