import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    this.leftFractions = const [0.15, 0.35, 0.55, 0.75, 0.9],
    this.rightFractions = const [0.15, 0.35, 0.55, 0.75, 0.9],
    this.lottieLeftIndex = 0,
    this.lottieRightIndex = 0,
    this.imageLeftIndex = 2,
    this.imageRightIndex = 2,
  });

  // Vertical anchor fractions for left and right gutters (0..1)
  final List<double> leftFractions;
  final List<double> rightFractions;

  // Which anchor index to use on each side for each asset type
  final int lottieLeftIndex;
  final int lottieRightIndex;
  final int imageLeftIndex;
  final int imageRightIndex;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Removed randomness for deterministic positioning

  final List<Offset> _lottiePositions = [];
  final List<Offset> _imagePositions = [];
  bool _positionsInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize positions once we have context/sizes
    if (!_positionsInitialized) {
      _initializePositionsForGutters();
      _positionsInitialized = true;
    }
  }

  void _initializePositionsForGutters() {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Scale for margin based on screen width
    final double scale = (screenWidth / 390.0).clamp(0.8, 2.4);
    final double baseAssetSize = 140.0 * scale; // max of lottie/png approx

    // Landmark image width is screenWidth / 1.8, centered. Compute gutters.
    final double imageWidth = screenWidth / 1.8;
    final double gutterWidth = (screenWidth - imageWidth) / 2.0;

    // Define left and right rectangles to place animations in.
    final Rect leftRect = Rect.fromLTWH(
      0,
      80, // avoid top bar slightly
      gutterWidth.clamp(0.0, screenWidth),
      (screenHeight - 160).clamp(0.0, screenHeight),
    );
    final Rect rightRect = Rect.fromLTWH(
      screenWidth - gutterWidth,
      80,
      gutterWidth.clamp(0.0, screenWidth),
      (screenHeight - 160).clamp(0.0, screenHeight),
    );

    _lottiePositions.clear();
    _imagePositions.clear();

    // Deterministic anchors from provided fractions
    List<Offset> anchorsForRect(Rect rect, List<double> fractions) {
      final double x = rect.left + rect.width / 2.0;
      final double top = rect.top + baseAssetSize * 0.5; // margin top
      final double usableHeight = (rect.height - baseAssetSize).clamp(
        0.0,
        rect.height,
      );
      return fractions.map((f) => Offset(x, top + usableHeight * f)).toList();
    }

    final List<Offset> leftAnchors = anchorsForRect(
      leftRect,
      widget.leftFractions,
    );
    final List<Offset> rightAnchors = anchorsForRect(
      rightRect,
      widget.rightFractions,
    );

    Offset safeGet(List<Offset> list, int index, Offset fallback) {
      if (index >= 0 && index < list.length) return list[index];
      return fallback;
    }

    // Assign fixed indices supplied from widget properties
    final Offset lottieLeft = safeGet(
      leftAnchors,
      widget.lottieLeftIndex,
      leftAnchors.isNotEmpty ? leftAnchors.first : Offset.zero,
    );
    final Offset lottieRight = safeGet(
      rightAnchors,
      widget.lottieRightIndex,
      rightAnchors.isNotEmpty ? rightAnchors.first : Offset.zero,
    );
    final Offset imageLeft = safeGet(
      leftAnchors,
      widget.imageLeftIndex,
      leftAnchors.isNotEmpty ? leftAnchors.last : Offset.zero,
    );
    final Offset imageRight = safeGet(
      rightAnchors,
      widget.imageRightIndex,
      rightAnchors.isNotEmpty ? rightAnchors.last : Offset.zero,
    );

    _lottiePositions.addAll([lottieLeft, lottieRight]);

    // Create 7 unique positions using only valid anchor indices (0-4)
    _imagePositions.addAll([
      imageRight, // Position 0 - Right side
      imageLeft, // Position 1 - Left side
      safeGet(
        leftAnchors,
        0,
        leftAnchors.isNotEmpty ? leftAnchors.first : Offset.zero,
      ), // Position 2 - Left top
      safeGet(
        rightAnchors,
        1,
        rightAnchors.isNotEmpty ? rightAnchors[1] : Offset.zero,
      ), // Position 3 - Right middle
      safeGet(
        leftAnchors,
        3,
        leftAnchors.isNotEmpty ? leftAnchors.last : Offset.zero,
      ), // Position 4 - Left bottom
      safeGet(
        rightAnchors,
        2,
        rightAnchors.isNotEmpty ? rightAnchors[2] : Offset.zero,
      ), // Position 5 - Right middle-high
      safeGet(
        leftAnchors,
        2,
        leftAnchors.isNotEmpty ? leftAnchors[2] : Offset.zero,
      ), // Position 6 - Left middle
    ]);
  }

  Widget _buildFloatingImage(
    String path,
    Offset base, {
    required double size,
    required double amplitude,
    double phase = 0.0, // Phase offset for different animation patterns
    double speed = 1.0, // Speed multiplier
    bool allowOverflow = false, // Allow part of image to extend outside
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        double time = _controller.value * 2 * pi * speed;
        double dx = base.dx + sin(time + phase) * amplitude;
        double dy = base.dy + cos(time + phase) * amplitude;

        // Clamp to keep image centered at base position but allow overflow
        if (!allowOverflow) {
          dx = dx.clamp(0.0, MediaQuery.of(context).size.width - size);
          dy = dy.clamp(0.0, MediaQuery.of(context).size.height - size);
        }

        return Positioned(
          left: dx,
          top: dy,
          child: Image.asset(
            path,
            width: size,
            height: size,
            opacity: const AlwaysStoppedAnimation(0.8),
          ),
        );
      },
    );
  }

  Widget _buildLottie(String asset, Offset pos, {required double size}) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          asset,
          repeat: true,
          animate: true,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double aspectRatio = screenWidth / screenHeight;

    // Dynamic sizing based on screen width
    // Phone (~375): ~95px, Tablet (~768): ~192px, Desktop (~1200): ~270px
    final double pngSize = (screenWidth * 0.25).clamp(80.0, 300.0);
    final double lottieSize = (screenWidth * 0.20).clamp(65.0, 250.0);
    final double amplitude = (screenWidth * 0.02).clamp(5.0, 25.0);

    // Edge offset as percentage of asset size
    final double edgeOffset = pngSize * 0.25;
    final double lottieEdgeOffset = lottieSize * 0.25;

    // For wide screens (laptops/desktops), push elements more to the edges
    // For narrow screens (phones), keep elements closer to visible area
    final double horizontalPush = aspectRatio > 1.5
        ? pngSize * 0.4
        : pngSize * 0.25;

    // Responsive edge-aligned positions
    final Offset topLeftEdge = Offset(-horizontalPush, -edgeOffset);
    final Offset topRightEdge = Offset(
      screenWidth - pngSize + horizontalPush,
      -edgeOffset * 0.6,
    );
    final Offset bottomLeftEdge = Offset(
      -horizontalPush,
      screenHeight - pngSize + edgeOffset,
    );
    final Offset leftCenterEdge = Offset(
      -horizontalPush,
      screenHeight * 0.4 - pngSize * 0.5,
    );
    final Offset rightCenterEdge = Offset(
      screenWidth - pngSize * 0.6 + horizontalPush * 0.5,
      screenHeight * 0.5 - pngSize * 0.5,
    );

    // Lottie positions - keep more visible on small screens
    final Offset lottieTopLeft = Offset(-lottieEdgeOffset, screenHeight * 0.12);
    final Offset lottieBottomRight = Offset(
      screenWidth - lottieSize + lottieEdgeOffset,
      screenHeight * 0.72,
    );

    // Flag position - top right area
    final Offset flagPosition = Offset(
      screenWidth - pngSize * 0.5,
      screenHeight * 0.22,
    );

    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2D1B69), // Dark purple top
              Color(0xFF4A34A3), // Lighter bottom
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none, // Allow children to overflow
          children: [
            // Top-left corner (partially outside)
            _buildFloatingImage(
              "assets/images/statue_of_liberty.png",
              topLeftEdge,
              size: pngSize,
              amplitude: amplitude * 0.6,
              phase: 0.0,
              speed: 1.0,
              allowOverflow: true,
            ),
            // Top-right corner (partially outside)
            _buildFloatingImage(
              "assets/images/brain.png",
              topRightEdge,
              size: pngSize,
              amplitude: amplitude * 0.6,
              phase: pi / 10,
              speed: 0.8,
              allowOverflow: true,
            ),

            // Bottom-left corner (partially outside)
            _buildFloatingImage(
              "assets/images/kermlin.png",
              bottomLeftEdge,
              size: pngSize,
              amplitude: amplitude * 0.5,
              phase: pi,
              speed: 1.2,
              allowOverflow: true,
            ),

            // Left center (partially outside)
            _buildFloatingImage(
              "assets/images/bizza_tower.png",
              leftCenterEdge,
              size: pngSize * 0.9,
              amplitude: amplitude * 0.5,
              phase: pi / 4,
              speed: 1.1,
              allowOverflow: true,
            ),
            // Right center (partially outside)
            _buildFloatingImage(
              "assets/images/poland_flag.png",
              rightCenterEdge,
              size: pngSize * 0.7,
              amplitude: amplitude * 0.4,
              phase: 2 * pi / 3,
              speed: 0.6,
              allowOverflow: true,
            ),

            // Two Lottie animations - positioned at edges
            _buildLottie(
              "assets/lotties/compass_anim.json",
              lottieTopLeft,
              size: lottieSize,
            ),
            _buildLottie(
              "assets/lotties/globe_anim.json",
              lottieBottomRight,
              size: lottieSize,
            ),

            // Bottom-right corner flag - rendered LAST so it appears on top
            _buildFloatingImage(
              "assets/images/palastine_flag.png",
              flagPosition,
              size: pngSize * 0.7,
              amplitude: amplitude * 0.3,
              phase: 3 * pi / 2,
              speed: 0.9,
              allowOverflow: true,
            ),

            // Overlay gradient for depth
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(190, 45, 27, 105), // Dark purple top
                      Color.fromARGB(190, 74, 52, 163), // Lighter bottom
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
