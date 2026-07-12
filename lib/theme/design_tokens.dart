import 'package:flutter/material.dart';

/// Design tokens for consistent spacing, typography, and visual hierarchy
class DesignTokens {
  // Spacing System (8pt grid)
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space18 = 18.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Typography Scale
  static const double fontSizeCaption = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeBodyLarge = 16.0;
  static const double fontSizeHeading6 = 18.0;
  static const double fontSizeHeading5 = 20.0;
  static const double fontSizeHeading4 = 24.0;
  static const double fontSizeHeading3 = 28.0;
  static const double fontSizeHeading2 = 32.0;
  static const double fontSizeHeading1 = 36.0;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 50.0;

  // Elevation/Shadow
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Content Spacing
  static const EdgeInsets paddingPageHorizontal = EdgeInsets.symmetric(
    horizontal: space20,
  );
  static const EdgeInsets paddingSection = EdgeInsets.symmetric(
    horizontal: space20,
    vertical: space16,
  );
  static const EdgeInsets paddingCard = EdgeInsets.all(space16);
  static const EdgeInsets paddingCardSmall = EdgeInsets.all(space12);

  // Section Spacing
  static const double sectionSpacingSmall = space20;
  static const double sectionSpacingMedium = space24;
  static const double sectionSpacingLarge = space32;
}

/// Typography styles following design system
class AppTypography {
  static const String fontFamily = 'Inter';

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: DesignTokens.fontSizeHeading1,
    fontWeight: FontWeight.bold,
    height: DesignTokens.lineHeightTight,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: DesignTokens.fontSizeHeading2,
    fontWeight: FontWeight.bold,
    height: DesignTokens.lineHeightTight,
    letterSpacing: -0.25,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: DesignTokens.fontSizeHeading3,
    fontWeight: FontWeight.bold,
    height: DesignTokens.lineHeightTight,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: DesignTokens.fontSizeHeading4,
    fontWeight: FontWeight.bold,
    height: DesignTokens.lineHeightNormal,
  );

  static const TextStyle heading5 = TextStyle(
    fontSize: DesignTokens.fontSizeHeading5,
    fontWeight: FontWeight.bold,
    height: DesignTokens.lineHeightNormal,
  );

  static const TextStyle heading6 = TextStyle(
    fontSize: DesignTokens.fontSizeHeading6,
    fontWeight: FontWeight.w600,
    height: DesignTokens.lineHeightNormal,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: DesignTokens.fontSizeBodyLarge,
    fontWeight: FontWeight.normal,
    height: DesignTokens.lineHeightNormal,
  );

  static const TextStyle body = TextStyle(
    fontSize: DesignTokens.fontSizeBody,
    fontWeight: FontWeight.normal,
    height: DesignTokens.lineHeightNormal,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: DesignTokens.fontSizeBody,
    fontWeight: FontWeight.w600,
    height: DesignTokens.lineHeightNormal,
  );

  static const TextStyle small = TextStyle(
    fontSize: DesignTokens.fontSizeSmall,
    fontWeight: FontWeight.normal,
    height: DesignTokens.lineHeightNormal,
  );

  static const TextStyle smallBold = TextStyle(
    fontSize: DesignTokens.fontSizeSmall,
    fontWeight: FontWeight.w600,
    height: DesignTokens.lineHeightNormal,
  );

  static const TextStyle caption = TextStyle(
    fontSize: DesignTokens.fontSizeCaption,
    fontWeight: FontWeight.normal,
    height: DesignTokens.lineHeightNormal,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: DesignTokens.fontSizeCaption,
    fontWeight: FontWeight.w600,
    height: DesignTokens.lineHeightNormal,
  );

  // Specialized Styles
  static const TextStyle locationText = TextStyle(
    fontSize: DesignTokens.fontSizeBodyLarge,
    fontWeight: FontWeight.w600,
    height: DesignTokens.lineHeightNormal,
    letterSpacing: 0.1,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: DesignTokens.fontSizeHeading5,
    fontWeight: FontWeight.bold,
    height: DesignTokens.lineHeightTight,
    letterSpacing: -0.1,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: DesignTokens.fontSizeBodyLarge,
    fontWeight: FontWeight.bold,
    height: DesignTokens.lineHeightTight,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: DesignTokens.fontSizeSmall,
    fontWeight: FontWeight.normal,
    height: DesignTokens.lineHeightNormal,
    color: Colors.black87,
  );

  static const TextStyle tag = TextStyle(
    fontSize: DesignTokens.fontSizeCaption,
    fontWeight: FontWeight.w500,
    height: DesignTokens.lineHeightTight,
  );
}
