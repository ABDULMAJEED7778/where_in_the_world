import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../utils/responsive.dart';

/// Number spinners for rounds and questions per player.
class LobbyRoundsQuestions extends StatelessWidget {
  final int numberOfRounds;
  final int questionsPerPlayer;
  final bool isSinglePlayer;
  final ValueChanged<int> onRoundsChanged;
  final ValueChanged<int> onQuestionsChanged;

  const LobbyRoundsQuestions({
    super.key,
    required this.numberOfRounds,
    required this.questionsPerPlayer,
    required this.isSinglePlayer,
    required this.onRoundsChanged,
    required this.onQuestionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isPhone(context)) {
      return Column(
        children: [
          _buildRoundsSection(context),
          const SizedBox(height: 16),
          _buildQuestionsSection(context),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildRoundsSection(context)),
        const SizedBox(width: 32),
        Expanded(child: _buildQuestionsSection(context)),
      ],
    );
  }

  Widget _buildRoundsSection(BuildContext context) {
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
            'NO. OF ROUNDS:',
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
            _buildNumberField(numberOfRounds),
            Column(
              children: [
                _buildArrowButton(Icons.keyboard_arrow_up, () {
                  if (numberOfRounds < 10) {
                    onRoundsChanged(numberOfRounds + 1);
                  }
                }),
                _buildArrowButton(Icons.keyboard_arrow_down, () {
                  if (numberOfRounds > 2) {
                    onRoundsChanged(numberOfRounds - 1);
                  }
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionsSection(BuildContext context) {
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
            isSinglePlayer ? 'NO. OF QUESTIONS:' : 'QUESTIONS PER PLAYER:',
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
            _buildNumberField(questionsPerPlayer),
            Column(
              children: [
                _buildArrowButton(Icons.keyboard_arrow_up, () {
                  if (questionsPerPlayer < 5) {
                    onQuestionsChanged(questionsPerPlayer + 1);
                  }
                }),
                _buildArrowButton(Icons.keyboard_arrow_down, () {
                  if (questionsPerPlayer > 2) {
                    onQuestionsChanged(questionsPerPlayer - 1);
                  }
                }),
              ],
            ),
          ],
        ),
      ],
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
