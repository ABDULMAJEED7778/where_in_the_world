import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rainbow_edge_lighting/rainbow_edge_lighting.dart';
import '../../services/audio_service.dart';

/// Ask-question input area with validation logic.
/// Only visible when it's the current player's turn.
class OnlineInteractionArea extends StatefulWidget {
  final bool isMyTurn;
  final bool canAskMore;
  final int questionsLimit;
  final int timeRemaining;
  final int turnDurationSeconds;
  final Function(String) onAskQuestion;

  const OnlineInteractionArea({
    super.key,
    required this.isMyTurn,
    required this.canAskMore,
    required this.questionsLimit,
    required this.timeRemaining,
    required this.turnDurationSeconds,
    required this.onAskQuestion,
  });

  @override
  State<OnlineInteractionArea> createState() => _OnlineInteractionAreaState();
}

class _OnlineInteractionAreaState extends State<OnlineInteractionArea>
    with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  String? _questionError;
  late AnimationController _askButtonFlashController;
  int _lastFlashedTime = -1;

  @override
  void initState() {
    super.initState();
    _askButtonFlashController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (widget.isMyTurn) {
      _startFlashAnimation();
    }
  }

  @override
  void didUpdateWidget(OnlineInteractionArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool shouldFlash = false;

    // Flash when it becomes our turn
    if (widget.isMyTurn && !oldWidget.isMyTurn) {
      shouldFlash = true;
    }

    // Flash at intervals (e.g. 45, 30, 15) when it is our turn
    if (!shouldFlash &&
        widget.isMyTurn &&
        widget.timeRemaining > 0 &&
        widget.timeRemaining < widget.turnDurationSeconds &&
        widget.timeRemaining % 15 == 0 &&
        _lastFlashedTime != widget.timeRemaining) {
      shouldFlash = true;
    }

    if (shouldFlash) {
      _lastFlashedTime = widget.timeRemaining;
      _startFlashAnimation();
    }
  }

  void _startFlashAnimation() {
    _askButtonFlashController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _askButtonFlashController.stop();
        _askButtonFlashController.reset();
      }
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _askButtonFlashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ask Question Section (Only if my turn AND haven't reached limit)
        if (widget.isMyTurn && widget.canAskMore) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF74E67C).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _questionController,
                  style: GoogleFonts.hanaleiFill(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask a yes/no question...',
                    hintStyle: GoogleFonts.hanaleiFill(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF74E67C)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                // Error message display
                if (_questionError != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _questionError!,
                            style: GoogleFonts.hanaleiFill(
                              color: Colors.red,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // ASK Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: AnimatedBuilder(
                    animation: _askButtonFlashController,
                    builder: (context, child) {
                      final isFlashing = _askButtonFlashController.isAnimating;
                      final flashValue = _askButtonFlashController.value;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: isFlashing
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF74E67C,
                                    ).withOpacity(flashValue * 0.5),
                                    blurRadius: 15 * flashValue,
                                    spreadRadius: 2 * flashValue,
                                  ),
                                ]
                              : [],
                        ),
                        child: RainbowEdgeLighting(
                          radius: 24, // Assuming height is 48, so radius is 24
                          thickness: 4.0,
                          enabled: isFlashing,
                          speed: 1.5,
                          clip: true,
                          child: child!,
                        ),
                      );
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        if (_questionController.text.isNotEmpty) {
                          final validationError = _validateQuestion(
                            _questionController.text.trim(),
                          );
                          if (validationError != null) {
                            setState(() {
                              _questionError = validationError;
                            });
                            return;
                          }
                          setState(() {
                            _questionError = null;
                          });
                          AudioService().playSecondaryButtonClick();
                          widget.onAskQuestion(_questionController.text);
                          _questionController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF74E67C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 2,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'ASK',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                            ),
                          ),
                          const Text(
                            'ASK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Show message when player has used all their questions
        if (widget.isMyTurn && !widget.canAskMore) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEA00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFEA00).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFFFEA00)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You've used all ${widget.questionsLimit} questions",
                        style: GoogleFonts.hanaleiFill(
                          color: const Color(0xFFFFEA00),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Make a guess or wait for others',
                        style: GoogleFonts.hanaleiFill(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// Validates if the question is acceptable.
  /// Returns error message if invalid, null if valid.
  String? _validateQuestion(String question) {
    final lowerQuestion = question.toLowerCase().trim();

    final yesNoIndicators = [
      'is ',
      'are ',
      'do ',
      'does ',
      'can ',
      'could ',
      'would ',
      'will ',
      'has ',
      'have ',
      'is the ',
      'are the ',
      'did ',
      'was ',
      'were ',
      'should ',
      'may ',
      'might ',
    ];

    final isYesNoQuestion = yesNoIndicators.any(
      (indicator) => lowerQuestion.startsWith(indicator),
    );

    if (!isYesNoQuestion) {
      return 'Ask a yes/no question (start with "Is", "Are", "Do", "Does", "Can", etc.)';
    }

    if (_isDirectCountryGuess(lowerQuestion)) {
      return 'Cannot ask about specific countries directly. Ask about geography, features, climate, or location instead.';
    }

    if (_isAmbiguousQuestion(lowerQuestion)) {
      return 'Question is too vague. Be more specific about what you\'re asking.';
    }

    final words = question.split(' ').where((w) => w.isNotEmpty).length;
    if (words < 3) {
      return 'Question is too short. Please provide more details.';
    }

    return null;
  }

  bool _isDirectCountryGuess(String question) {
    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains(' in ') ||
        lowerQuestion.contains(' near ') ||
        lowerQuestion.contains(' on ') ||
        lowerQuestion.contains(' located ') ||
        lowerQuestion.contains(' part of ')) {
      return false;
    }

    final countryGuessPatterns = [
      RegExp(r'is\s+it\s+(a\s+)?[a-z\s]+\??\s*$', caseSensitive: false),
      RegExp(r'is\s+this\s+(a\s+)?[a-z\s]+\??\s*$', caseSensitive: false),
      RegExp(r'is\s+the\s+country\s+[a-z\s]+\??\s*$', caseSensitive: false),
    ];

    for (var pattern in countryGuessPatterns) {
      if (pattern.hasMatch(question)) {
        return true;
      }
    }

    return false;
  }

  bool _isAmbiguousQuestion(String question) {
    final lowerQuestion = question.toLowerCase();

    final vaguePhrases = [
      'is it?',
      'are they?',
      'do you?',
      'can it?',
      'what is it?',
      'who is it?',
      'where is it?',
      'when is it?',
      'why is it?',
      'how is it?',
    ];

    for (var phrase in vaguePhrases) {
      if (lowerQuestion.trim() == phrase) {
        return true;
      }
    }

    final hasMultipleClauses =
        lowerQuestion.split(' and ').length > 2 ||
        lowerQuestion.split(' or ').length > 2;

    if (hasMultipleClauses) {
      return true;
    }

    return false;
  }
}
