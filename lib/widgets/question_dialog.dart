import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'question_display_overlay.dart';

class QuestionDialog extends StatefulWidget {
  const QuestionDialog({super.key});

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _canSubmitQuestion = false;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update button state
    _questionController.addListener(() {
      final canSubmit = _questionController.text.trim().isNotEmpty;
      if (canSubmit != _canSubmitQuestion) {
        setState(() {
          _canSubmitQuestion = canSubmit;
        });
      }
    });
  }

  @override
  void dispose() {
    // The listener is automatically removed when the controller is disposed
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = context.watch<GameProvider>().gameState.currentPlayer;
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic responsive values based on screen width
    // Dialog width: 92% on small screens, max 500px on large screens
    final dialogWidth = (screenWidth * 0.85).clamp(280.0, 500.0);

    // Font sizes scale with screen width
    final titleFontSize = (screenWidth * 0.045).clamp(16.0, 22.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(12.0, 16.0);
    final hintFontSize = (screenWidth * 0.028).clamp(10.0, 14.0);

    // Padding and spacing scale with screen width
    final padding = (screenWidth * 0.04).clamp(14.0, 24.0);
    final borderRadius = (screenWidth * 0.03).clamp(10.0, 20.0);

    // Button sizing
    final buttonHeight = (screenWidth * 0.1).clamp(36.0, 48.0);
    final playerBadgePadding = (screenWidth * 0.02).clamp(6.0, 12.0);

    return Dialog(
      backgroundColor: const Color(0xFF2D1B69).withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ask a Question',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: playerBadgePadding * 1.5,
                    vertical: playerBadgePadding * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 240, 0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        currentPlayer?.name.toUpperCase() ?? 'PLAYER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: hintFontSize,
                          letterSpacing: 1.0,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.5
                            ..color = Colors.black,
                        ),
                      ),
                      Text(
                        currentPlayer?.name.toUpperCase() ?? 'PLAYER',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: hintFontSize,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: padding),

            // Question input
            TextField(
              controller: _questionController,
              style: TextStyle(color: Colors.white, fontSize: bodyFontSize),
              decoration: InputDecoration(
                hintText: 'Enter your yes/no question...',
                hintStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: bodyFontSize * 0.9,
                ),
                contentPadding: EdgeInsets.all(padding * 0.75),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius * 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius * 0.5),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius * 0.5),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
              cursorColor: Colors.white,
              cursorWidth: 2,
              maxLines: 3,
            ),

            // Loading indicator
            if (_isLoading) ...[
              SizedBox(height: padding),
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: padding * 0.75),
                    Text(
                      'AI is thinking...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: hintFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Error message
            if (_errorMessage != null) ...[
              SizedBox(height: padding),
              Container(
                padding: EdgeInsets.all(padding * 0.75),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: bodyFontSize * 1.3,
                    ),
                    SizedBox(width: padding * 0.5),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: hintFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: padding * 0.75),

            // Helper text
            Text(
              'The AI will answer your question about the COUNTRY where this landmark is located.',
              style: TextStyle(color: Colors.white70, fontSize: hintFontSize),
              textAlign: TextAlign.left,
            ),

            SizedBox(height: padding),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: padding * 0.5,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: bodyFontSize,
                    ),
                  ),
                ),
                SizedBox(width: padding * 0.5),
                SizedBox(
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: (_canSubmitQuestion && !_isLoading)
                        ? _submitQuestion
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF74E67C),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius * 0.5),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: padding),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: bodyFontSize * 1.3,
                            height: bodyFontSize * 1.3,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Ask AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: bodyFontSize,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuestion() async {
    if (!_canSubmitQuestion || _isLoading) return;

    final question = _questionController.text.trim();

    // Validate the question before submitting
    final validationError = _validateQuestion(question);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gameProvider = context.read<GameProvider>();
      await gameProvider.askQuestion(question);

      if (mounted) {
        // Get the last question to retrieve the AI answer
        final lastQuestion = gameProvider.gameState.currentRoundQuestions.last;

        // Close the dialog
        Navigator.of(context).pop();

        // Show the question display overlay
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: QuestionDisplayOverlay(
              question: lastQuestion.text,
              answer: lastQuestion.answer,
              askedBy: lastQuestion.askedBy,
              onDismiss: () => Navigator.of(context).pop(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to get AI response. Please try again.';
        });
      }
    }
  }

  /// Validates if the question is acceptable
  /// Returns error message if invalid, null if valid
  String? _validateQuestion(String question) {
    final lowerQuestion = question.toLowerCase().trim();

    // Check for yes/no question indicators
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

    // Check for direct country guessing (is it [country]?)
    if (_isDirectCountryGuess(lowerQuestion)) {
      return 'Cannot ask about specific countries directly. Ask about geography, geography features, climate, or location instead.';
    }

    // Check for too-vague questions
    if (_isAmbiguousQuestion(lowerQuestion)) {
      return 'Question is too vague. Be more specific about what you\'re asking.';
    }

    // Check for questions that are too short/simple
    final words = question.split(' ').where((w) => w.isNotEmpty).length;
    if (words < 3) {
      return 'Question is too short. Please provide more details.';
    }

    return null; // Question is valid
  }

  /// Check if the question is trying to guess a specific country
  bool _isDirectCountryGuess(String question) {
    final lowerQuestion = question.toLowerCase();

    // If it contains locational prepositions, it's likely a valid geography question
    if (lowerQuestion.contains(' in ') ||
        lowerQuestion.contains(' near ') ||
        lowerQuestion.contains(' on ') ||
        lowerQuestion.contains(' located ') ||
        lowerQuestion.contains(' part of ')) {
      return false;
    }

    // Pattern: "is it [country]?" or "is the [country]?" etc.
    final countryGuessPatterns = [
      RegExp(r'is\s+it\s+(a\s+)?[a-z\s]+\??\s*$', caseSensitive: false),
      RegExp(r'is\s+this\s+(a\s+)?[a-z\s]+\??\s*$', caseSensitive: false),
      RegExp(r'is\s+the\s+country\s+[a-z\s]+\??\s*$', caseSensitive: false),
    ];

    for (var pattern in countryGuessPatterns) {
      if (pattern.hasMatch(question)) {
        // Extract the potential country name
        final match = pattern.firstMatch(question);
        if (match != null) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check for ambiguous or poorly formed questions
  bool _isAmbiguousQuestion(String question) {
    final lowerQuestion = question.toLowerCase();

    // Questions without clear subject
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

    // Questions with multiple independent clauses (likely yes/no mashup)
    final hasMultipleClauses =
        lowerQuestion.split(' and ').length > 2 ||
        lowerQuestion.split(' or ').length > 2;

    if (hasMultipleClauses) {
      return true;
    }

    return false;
  }
}
