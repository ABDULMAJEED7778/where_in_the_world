import 'package:flutter/material.dart';

/// Screen size categories for responsive design
enum ScreenSize {
  phone, // < 600px - Small phones, iPhone SE, Android compacts
  tablet, // 600-900px - Large phones, small tablets, iPad Mini
  laptop, // 900-1200px - Tablets, small laptops, iPad Pro
  desktop, // > 1200px - Large monitors, TVs, Web browsers
}

/// Utility class for responsive design throughout the app
///
/// Usage:
/// ```dart
/// // Get current screen size
/// final size = Responsive.getScreenSize(context);
///
/// // Check screen size
/// if (Responsive.isPhone(context)) { ... }
///
/// // Get responsive value
/// final padding = Responsive.value<double>(context,
///   phone: 16,
///   tablet: 24,
///   laptop: 32,
///   desktop: 40,
/// );
/// ```
class Responsive {
  // Breakpoint thresholds
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 900;
  static const double laptopMaxWidth = 1200;

  /// Get the current screen size category based on width
  static ScreenSize getScreenSize(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < phoneMaxWidth) return ScreenSize.phone;
    if (width < tabletMaxWidth) return ScreenSize.tablet;
    if (width < laptopMaxWidth) return ScreenSize.laptop;
    return ScreenSize.desktop;
  }

  /// Get screen width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Check if current screen is phone size
  static bool isPhone(BuildContext context) =>
      getScreenSize(context) == ScreenSize.phone;

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) =>
      getScreenSize(context) == ScreenSize.tablet;

  /// Check if current screen is laptop size
  static bool isLaptop(BuildContext context) =>
      getScreenSize(context) == ScreenSize.laptop;

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) =>
      getScreenSize(context) == ScreenSize.desktop;

  /// Check if screen is small (phone or tablet)
  static bool isSmall(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.phone || size == ScreenSize.tablet;
  }

  /// Check if screen is large (laptop or desktop)
  static bool isLarge(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.laptop || size == ScreenSize.desktop;
  }

  /// Get a responsive value based on screen size
  /// Falls back to smaller size values if not specified
  ///
  /// Example:
  /// ```dart
  /// final fontSize = Responsive.value<double>(context,
  ///   phone: 14,
  ///   tablet: 16,
  ///   laptop: 18,
  ///   desktop: 20,
  /// );
  /// ```
  static T value<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? laptop,
    T? desktop,
  }) {
    switch (getScreenSize(context)) {
      case ScreenSize.phone:
        return phone;
      case ScreenSize.tablet:
        return tablet ?? phone;
      case ScreenSize.laptop:
        return laptop ?? tablet ?? phone;
      case ScreenSize.desktop:
        return desktop ?? laptop ?? tablet ?? phone;
    }
  }

  /// Get responsive padding
  static EdgeInsets padding(
    BuildContext context, {
    EdgeInsets phone = const EdgeInsets.all(16),
    EdgeInsets? tablet,
    EdgeInsets? laptop,
    EdgeInsets? desktop,
  }) {
    return value<EdgeInsets>(
      context,
      phone: phone,
      tablet: tablet,
      laptop: laptop,
      desktop: desktop,
    );
  }

  /// Get responsive horizontal padding only
  static EdgeInsets horizontalPadding(BuildContext context) {
    return value<EdgeInsets>(
      context,
      phone: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 24),
      laptop: const EdgeInsets.symmetric(horizontal: 32),
      desktop: const EdgeInsets.symmetric(horizontal: 48),
    );
  }

  /// Get responsive font size multiplier
  static double fontScale(BuildContext context) {
    return value<double>(
      context,
      phone: 1.0,
      tablet: 1.1,
      laptop: 1.15,
      desktop: 1.2,
    );
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, {double base = 24}) {
    return base * fontScale(context);
  }

  /// Get maximum content width for centered layouts
  static double maxContentWidth(BuildContext context) {
    return value<double>(
      context,
      phone: double.infinity,
      tablet: 540,
      laptop: 800,
      desktop: 1000,
    );
  }

  /// Get dialog width
  static double dialogWidth(BuildContext context) {
    final screenWidth = width(context);
    return value<double>(
      context,
      phone: screenWidth * 0.95,
      tablet: screenWidth * 0.75,
      laptop: 500,
      desktop: 560,
    );
  }

  /// Get number of columns for grid layouts
  static int gridColumns(BuildContext context) {
    return value<int>(context, phone: 1, tablet: 2, laptop: 3, desktop: 4);
  }

  /// Get button height
  static double buttonHeight(BuildContext context) {
    return value<double>(
      context,
      phone: 44,
      tablet: 48,
      laptop: 52,
      desktop: 56,
    );
  }

  /// Get spacing between elements
  static double spacing(BuildContext context, {double base = 16}) {
    return value<double>(
      context,
      phone: base,
      tablet: base * 1.25,
      laptop: base * 1.5,
      desktop: base * 1.75,
    );
  }

  /// Get border radius
  static double borderRadius(BuildContext context, {double base = 12}) {
    return value<double>(
      context,
      phone: base,
      tablet: base * 1.1,
      laptop: base * 1.2,
      desktop: base * 1.3,
    );
  }

  /// Check if layout should be horizontal (side-by-side)
  /// Useful for switching between column and row layouts
  static bool useHorizontalLayout(BuildContext context) {
    return isLarge(context);
  }

  /// Get the flex ratio for main content in horizontal layouts
  static int mainContentFlex(BuildContext context) {
    return value<int>(context, phone: 1, tablet: 1, laptop: 3, desktop: 3);
  }

  /// Get the flex ratio for side panel in horizontal layouts
  static int sidePanelFlex(BuildContext context) {
    return value<int>(context, phone: 1, tablet: 1, laptop: 2, desktop: 2);
  }
}

/// A widget that rebuilds based on screen size changes
///
/// Usage:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, screenSize) {
///     if (screenSize == ScreenSize.phone) {
///       return PhoneLayout();
///     }
///     return DesktopLayout();
///   },
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Responsive.getScreenSize(context);
        return builder(context, screenSize);
      },
    );
  }
}

/// A widget that shows different children based on screen size
///
/// Usage:
/// ```dart
/// ResponsiveWidget(
///   phone: MobileView(),
///   tablet: TabletView(),
///   laptop: LaptopView(),
///   desktop: DesktopView(),
/// )
/// ```
class ResponsiveWidget extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;
  final Widget? laptop;
  final Widget? desktop;

  const ResponsiveWidget({
    required this.phone,
    this.tablet,
    this.laptop,
    this.desktop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Responsive.value<Widget>(
      context,
      phone: phone,
      tablet: tablet,
      laptop: laptop,
      desktop: desktop,
    );
  }
}

/// A container that centers content with a max width
/// Useful for preventing content from stretching too wide on large screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  const ResponsiveContainer({
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? Responsive.maxContentWidth(context);
    final effectivePadding = padding ?? Responsive.horizontalPadding(context);

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}

/// Extension methods for convenient responsive access
extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => Responsive.getScreenSize(this);
  bool get isPhone => Responsive.isPhone(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isLaptop => Responsive.isLaptop(this);
  bool get isDesktop => Responsive.isDesktop(this);
  bool get isSmallScreen => Responsive.isSmall(this);
  bool get isLargeScreen => Responsive.isLarge(this);
  double get screenWidth => Responsive.width(this);
  double get screenHeight => Responsive.height(this);
}
