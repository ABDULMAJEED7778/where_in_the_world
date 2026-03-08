import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

/// Collapsible rules section with mode-specific text.
class LobbyRulesSection extends StatefulWidget {
  final bool isSinglePlayer;

  const LobbyRulesSection({super.key, required this.isSinglePlayer});

  @override
  State<LobbyRulesSection> createState() => _LobbyRulesSectionState();
}

class _LobbyRulesSectionState extends State<LobbyRulesSection> {
  bool _rulesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = Responsive.isPhone(context) || screenHeight < 900;
    final showExpanded = !isSmallScreen || _rulesExpanded;

    final labelFontSize = Responsive.value<double>(
      context,
      phone: 14,
      tablet: 16,
      laptop: 17,
      desktop: 18,
    );

    final ruleFontSize = Responsive.value<double>(
      context,
      phone: 11,
      tablet: 12,
      laptop: 13,
      desktop: 14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: isSmallScreen
              ? () => setState(() => _rulesExpanded = !_rulesExpanded)
              : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 8 : 0,
              horizontal: isSmallScreen ? 4 : 0,
            ),
            decoration: isSmallScreen
                ? BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: Responsive.value<double>(
                    context,
                    phone: 18,
                    tablet: 20,
                    laptop: 22,
                    desktop: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'RULES:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                if (isSmallScreen) ...[
                  const Spacer(),
                  Icon(
                    showExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.isSinglePlayer
                  ? _buildSinglePlayerRules(ruleFontSize)
                  : _buildPartyModeRules(ruleFontSize),
            ),
          ),
          crossFadeState: showExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  List<Widget> _buildSinglePlayerRules(double fontSize) {
    return [
      _ruleText(
        '• ASK YES/NO QUESTIONS TO NARROW DOWN THE LANDMARK\'S LOCATION.',
        fontSize,
      ),
      const SizedBox(height: 4),
      _ruleText(
        '• ONCE YOU GUESS, YOU CANNOT CANCEL OR CHANGE YOUR ANSWER.',
        fontSize,
      ),
      const SizedBox(height: 4),
      _ruleText(
        '• CORRECT GUESS: +10 POINTS. WRONG GUESS: 0 POINTS.',
        fontSize,
      ),
      const SizedBox(height: 4),
      _ruleText('• TRY TO GUESS WITH AS FEW QUESTIONS AS POSSIBLE!', fontSize),
    ];
  }

  List<Widget> _buildPartyModeRules(double fontSize) {
    return [
      _ruleText(
        '• PLAYER WHO ASKED THE LAST QUESTION HAS THE PRIORITY TO GUESS.',
        fontSize,
      ),
      const SizedBox(height: 4),
      _ruleText(
        '• CANCELLATION OF A GUESS AFTER PRESSING THE GUESS BUTTON IS NOT ALLOWED.',
        fontSize,
      ),
      const SizedBox(height: 4),
      _ruleText(
        '• PLAYERS ARE ALLOWED TO DIRECTLY GUESS AT THEIR TURN POINT IN THE GAME.',
        fontSize,
      ),
      const SizedBox(height: 4),
      _ruleText(
        '• IN CASE NO PLAYER GUESSES THE RIGHT COUNTRY, THE PLAYER WITH THE NEAREST GUESS GETS 5 POINTS.',
        fontSize,
      ),
    ];
  }

  Widget _ruleText(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(color: Colors.white70, fontSize: fontSize),
      textAlign: TextAlign.justify,
    );
  }
}
