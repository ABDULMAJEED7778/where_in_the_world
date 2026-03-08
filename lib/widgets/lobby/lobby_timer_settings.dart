import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/audio_service.dart';
import '../../utils/responsive.dart';

/// Timer settings selector for party/single mode lobbies.
class LobbyTimerSettings extends StatelessWidget {
  final bool isTimerEnabled;
  final int timerDuration;
  final ValueChanged<bool> onTimerToggled;
  final ValueChanged<int> onDurationChanged;

  const LobbyTimerSettings({
    super.key,
    required this.isTimerEnabled,
    required this.timerDuration,
    required this.onTimerToggled,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isPhone(context)) {
      return Column(
        children: [
          _buildToggleSection(context),
          const SizedBox(height: 16),
          _buildDurationSection(context),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildToggleSection(context)),
        const SizedBox(width: 32),
        Expanded(child: _buildDurationSection(context)),
      ],
    );
  }

  Widget _buildToggleSection(BuildContext context) {
    final labelFontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 17,
      desktop: 18,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'TURN TIMER:',
            style: TextStyle(
              color: Colors.white,
              fontSize: labelFontSize,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            AudioService().playSecondaryButtonClick();
            onTimerToggled(!isTimerEnabled);
          },
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isTimerEnabled
                    ? const Color(0xFF74E67C)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isTimerEnabled ? Icons.timer : Icons.timer_off,
                  color: isTimerEnabled
                      ? const Color(0xFF74E67C)
                      : Colors.black54,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isTimerEnabled ? 'ON' : 'OFF',
                  style: GoogleFonts.hanaleiFill(
                    fontSize: 18,
                    color: isTimerEnabled
                        ? const Color(0xFF74E67C)
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection(BuildContext context) {
    final labelFontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 17,
      desktop: 18,
    );

    return Opacity(
      opacity: isTimerEnabled ? 1.0 : 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'TIMER DURATION:',
              style: TextStyle(
                color: Colors.white,
                fontSize: labelFontSize,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              _buildNumberField(timerDuration),
              Column(
                children: [
                  _buildArrowButton(Icons.keyboard_arrow_up, () {
                    if (!isTimerEnabled) return;
                    if (timerDuration < 180) {
                      int newDuration =
                          timerDuration + 15 - (timerDuration % 15);
                      onDurationChanged(newDuration.clamp(30, 180));
                    }
                  }),
                  _buildArrowButton(Icons.keyboard_arrow_down, () {
                    if (!isTimerEnabled) return;
                    if (timerDuration > 30) {
                      int newDuration = timerDuration - (timerDuration % 15);
                      if (newDuration == timerDuration) newDuration -= 15;
                      onDurationChanged(newDuration.clamp(30, 180));
                    }
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(int value) {
    return Container(
      width: 50,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          bottomLeft: Radius.circular(12.0),
        ),
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        AudioService().playSecondaryButtonClick();
        onTap();
      },
      child: Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: icon == Icons.keyboard_arrow_down
              ? const BorderRadius.only(bottomRight: Radius.circular(12.0))
              : const BorderRadius.only(topRight: Radius.circular(12.0)),
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }
}
