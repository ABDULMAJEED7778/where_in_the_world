import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';

class VisualFeedbackOverlay extends StatefulWidget {
  final Widget child;
  final Stream<GameEvent>? eventStream;

  const VisualFeedbackOverlay({
    super.key,
    required this.child,
    this.eventStream,
  });

  @override
  State<VisualFeedbackOverlay> createState() => _VisualFeedbackOverlayState();
}

class _VisualFeedbackOverlayState extends State<VisualFeedbackOverlay>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _flashController;

  Color _flashColor = Colors.transparent;
  bool _showBalloon = false;
  bool _showTimeout = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    // Shake Animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _shakeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    // Flash Animation
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Listen to events
    if (widget.eventStream != null) {
      _subscription = widget.eventStream!.listen(_handleGameEvent);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final gameProvider = context.read<GameProvider>();
          _subscription = gameProvider.events.listen(_handleGameEvent);
        } catch (e) {
          debugPrint(
            'VisualFeedbackOverlay: No GameProvider found and no eventStream provided',
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(VisualFeedbackOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.eventStream != oldWidget.eventStream) {
      _subscription?.cancel();
      if (widget.eventStream != null) {
        _subscription = widget.eventStream!.listen(_handleGameEvent);
      } else {
        // Resubscribe to GameProvider if needed, or just leave it cancelled
        // if this use case isn't expected to switch back and forth.
        // For now, let's just re-init if stream is removed.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            final gameProvider = context.read<GameProvider>();
            _subscription = gameProvider.events.listen(_handleGameEvent);
          } catch (e) {
            // Silently fail if no provider
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _shakeController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  void _handleGameEvent(GameEvent event) {
    switch (event) {
      case GameEvent.correctGuess:
        _playCorrectFeedback();
        break;
      case GameEvent.incorrectGuess:
        _playIncorrectFeedback();
        break;
      case GameEvent.turnTimeout:
        _playTimeoutFeedback();
        break;
      case GameEvent.roundTransition:
        _playRoundTransition();
        break;
      case GameEvent.gameEnd:
        // Already handled by screens, but could add confetti here
        break;
    }
  }

  void _playCorrectFeedback() {
    // Green Flash only, removed globe animation per request
    setState(() {
      _flashColor = Colors.green.withOpacity(0.3);
      // _showGlobe = true; // Globe removed
    });

    _flashController.reset();
    _flashController.forward().then((_) => _flashController.reverse());
  }

  void _playIncorrectFeedback() {
    // Red Flash + Shake
    setState(() {
      _flashColor = Colors.red.withOpacity(0.3);
    });

    _shakeController.forward(from: 0.0);
    _flashController.reset();
    _flashController.forward().then((_) => _flashController.reverse());
  }

  void _playTimeoutFeedback() {
    setState(() {
      _showTimeout = true;
      _flashColor = Colors.orange.withOpacity(0.4);
    });

    _shakeController.forward(from: 0.0);
    _flashController.reset();
    _flashController.forward().then((_) => _flashController.reverse());

    // Hide animation after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showTimeout = false;
        });
      }
    });
  }

  void _playRoundTransition() {
    setState(() {
      _showBalloon = true;
    });

    // Hide transition animation after it completes
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showBalloon = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final dx = sin(_shakeAnimation.value * pi * 4) * 10;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Stack(
            children: [
              widget.child,

              // Flash Overlay
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _flashController,
                  builder: (context, child) {
                    // We blend the flash color based on controller value
                    return Container(
                      color: _flashColor.withOpacity(
                        (_flashController.value * 0.5).clamp(0.0, 1.0),
                      ),
                    );
                  },
                ),
              ),

              // Time Out Overlay
              if (_showTimeout)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.orangeAccent,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_off,
                              color: Colors.orangeAccent,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "TIME'S UP!",
                              style: GoogleFonts.hanaleiFill(
                                color: Colors.orangeAccent,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                    offset: Offset(2, 2),
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
