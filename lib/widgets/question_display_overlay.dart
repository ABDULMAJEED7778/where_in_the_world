import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class QuestionDisplayOverlay extends StatefulWidget {
  final String question;
  final bool answer;
  final String askedBy;
  final VoidCallback onDismiss;

  const QuestionDisplayOverlay({
    super.key,
    required this.question,
    required this.answer,
    required this.askedBy,
    required this.onDismiss,
  });

  @override
  State<QuestionDisplayOverlay> createState() => _QuestionDisplayOverlayState();
}

class _QuestionDisplayOverlayState extends State<QuestionDisplayOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismiss();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color answerColor = widget.answer
        ? const Color(0xFF74E67C) // Vibrant Green
        : const Color(0xFFE63C3D); // Vibrant Red

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Blurred background
              Opacity(
                opacity: _opacityAnimation.value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ),
              // Question card
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 48,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D1B69).withOpacity(0.0),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: answerColor.withOpacity(0.8),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: answerColor.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // "Who asked" label
                          Text(
                            "${widget.askedBy.toUpperCase()} ASKED:",
                            style: GoogleFonts.montserrat(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Question text
                          Text(
                            widget.question.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hanaleiFill(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Answer with Icon
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: answerColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: answerColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.answer ? 'YES' : 'NO',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.hanaleiFill(
                                    textStyle: TextStyle(
                                      color: answerColor,
                                      fontSize: 64,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 4.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
