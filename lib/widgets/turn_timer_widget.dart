import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TurnTimerWidget extends StatelessWidget {
  final int timeRemaining;
  final int totalTime;
  final double size;
  final bool isPaused;
  final bool isEnabled;

  const TurnTimerWidget({
    super.key,
    required this.timeRemaining,
    this.totalTime = 60,
    this.size = 60.0,
    this.isPaused = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress (0.0 to 1.0)
    final progress = timeRemaining / totalTime;

    // Choose premium color based on remaining time
    Color timerColor = const Color(0xFF00E676); // Vibrant Green
    if (!isEnabled) {
      timerColor = const Color(0xFF00B0FF); // Cool Blue for disabled timer
    } else if (timeRemaining <= 5) {
      timerColor = const Color(
        0xFFFF3D00,
      ); // Bright Red for critical (changed from 10 to 5 for better pacing)
    } else if (timeRemaining <= 15) {
      timerColor = const Color(
        0xFFFFB300,
      ); // Amber/Orange for warning (more visible than yellow)
    }

    // Override color when paused
    if (isPaused) {
      timerColor = Colors.white54;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Glow and Glassmorphism
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(
                0.4,
              ), // Dark background for contrast
              boxShadow: [
                BoxShadow(
                  color: timerColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // Circular Progress
          CircularProgressIndicator(
            value: !isEnabled ? 1.0 : (isPaused ? null : progress),
            strokeWidth: size * 0.1, // Scale stroke width based on size
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),
          // Timer Text
          Center(
            child: !isEnabled
                ? Icon(
                    Icons.all_inclusive_rounded,
                    color: timerColor,
                    size: size * 0.45,
                  )
                : (isPaused
                      ? Icon(
                          Icons.hourglass_empty_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: size * 0.45,
                        )
                      : Text(
                          '$timeRemaining',
                          style: GoogleFonts.hanaleiFill(
                            color: timerColor,
                            fontSize: size * 0.45,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        )),
          ),
        ],
      ),
    );
  }
}
