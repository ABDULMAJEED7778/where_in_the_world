import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:rainbow_edge_lighting/rainbow_edge_lighting.dart';
import 'package:provider/provider.dart';
import '../../providers/online_game_provider.dart';

/// Landmark image display with loading animation, zoom hint, and
/// tap-to-fullscreen with rotation controls.
class OnlineLandmarkImage extends StatelessWidget {
  final String imageUrl;
  final bool isWide;

  const OnlineLandmarkImage({
    super.key,
    required this.imageUrl,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = isWide ? double.infinity : screenWidth * 0.9;

    Widget imageWidget = Container(
      width: isWide ? null : imageWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            spreadRadius: 4,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: RainbowEdgeLighting(
              radius: 20,
              thickness: 12.0,
              enabled: true,
              speed: 0.1,
              clip: true,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          final bool isLoaded =
                              frame != null || wasSynchronouslyLoaded;

                          if (isLoaded) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) {
                                context
                                    .read<OnlineGameProvider>()
                                    .onImageLoaded();
                              }
                            });
                          }

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              child,
                              if (!isLoaded)
                                Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Lottie.asset(
                                      'assets/lotties/Camera.json',
                                      width: isWide ? 200 : imageWidth / 4,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: Center(
                          child: Lottie.asset(
                            'assets/lotties/Camera.json',
                            width: isWide ? 200 : imageWidth / 4,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                  // Tap hint
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_in,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'TAP TO ZOOM',
                            style: GoogleFonts.hanaleiFill(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: () => _openFullScreenImage(context, imageUrl),
      child: imageWidget,
    );
  }

  void _openFullScreenImage(BuildContext context, String imageUrl) {
    int rotationQuarter = 0;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  body: Stack(
                    children: [
                      InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isRotated = rotationQuarter == 1;
                              final screenWidth = constraints.maxWidth;
                              final screenHeight = constraints.maxHeight;

                              Widget imgWidget = Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                width: isRotated ? screenHeight : null,
                                height: isRotated ? screenWidth : null,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: const Color(0xFF74E67C),
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                              );

                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isRotated
                                    ? RotatedBox(
                                        key: const ValueKey('rotated'),
                                        quarterTurns: 1,
                                        child: SizedBox(
                                          width: screenHeight,
                                          height: screenWidth,
                                          child: imgWidget,
                                        ),
                                      )
                                    : SizedBox(
                                        key: const ValueKey('normal'),
                                        width: screenWidth,
                                        height: screenHeight,
                                        child: imgWidget,
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Top buttons row
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        right: 16,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  rotationQuarter = rotationQuarter == 0
                                      ? 1
                                      : 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.rotate_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Zoom hint
                      Positioned(
                        bottom: MediaQuery.of(context).padding.bottom + 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Pinch to zoom • Double-tap to reset',
                              style: GoogleFonts.hanaleiFill(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
