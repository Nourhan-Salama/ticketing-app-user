import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Private constructor
  ResponsiveHelper._();

  // Screen size and orientation related helpers
  static Size screenSize(BuildContext context) => MediaQuery.sizeOf(context);
  static double screenWidth(BuildContext context) => screenSize(context).width;
  static double screenHeight(BuildContext context) => screenSize(context).height;
  static Orientation orientation(BuildContext context) => MediaQuery.orientationOf(context);
  static bool isPortrait(BuildContext context) => orientation(context) == Orientation.portrait;
  static bool isLandscape(BuildContext context) => orientation(context) == Orientation.landscape;

  // Device type detection
  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) => screenWidth(context) >= 600 && screenWidth(context) < 1200;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1200;

  // Responsive layout helpers
  static double responsiveValue({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile * 1.5;
    return desktop ?? mobile * 2;
  }

  // Percentage-based dimensions
  static double widthPercent(BuildContext context, double percent) => screenWidth(context) * percent;
  static double heightPercent(BuildContext context, double percent) => screenHeight(context) * percent;

  // Text scaling helpers
  static double textScaleFactor(BuildContext context) => MediaQuery.textScaleFactorOf(context);
  static double responsiveTextSize(BuildContext context, double baseSize) => 
      baseSize * (isMobile(context) ? 1 : 1.2);

  // Padding and margins
  static EdgeInsets responsivePadding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: responsiveValue(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
    ),
    vertical: 16,
  );

  // Safe area dimensions
  static EdgeInsets safeAreaPadding(BuildContext context) => MediaQuery.paddingOf(context);
  static double safeAreaTop(BuildContext context) => safeAreaPadding(context).top;
  static double safeAreaBottom(BuildContext context) => safeAreaPadding(context).bottom;

  // Aspect ratio helpers
  static double aspectHeight({
    required BuildContext context,
    required double aspectRatio,
    required double width,
  }) => width / aspectRatio;

  static double aspectWidth({
    required BuildContext context,
    required double aspectRatio,
    required double height,
  }) => height * aspectRatio;

  // Platform-aware breakpoints
  static double breakpointMobile = 600;
  static double breakpointTablet = 1200;
}