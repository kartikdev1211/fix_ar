import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
//  FixAR — App Constants
//  Single source of truth for all colors, gradients & sizes.
// ════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ── BACKGROUNDS ──────────────────────────────────────────
  /// Primary dark background used on every Scaffold
  static const Color background = Color(0xFF080810);

  /// Slightly lighter surface for cards, nav bars, headers
  static const Color surface = Color(0xFF0D0D1A);

  /// Card used in featured tutorials
  static const Color cardDark = Color(0xFF0D1525);

  /// Deep teal-tinted background (scan banner gradient start)
  static const Color bannerStart = Color(0xFF00261F);

  /// Deep blue-tinted background (scan banner gradient end)
  static const Color bannerEnd = Color(0xFF001A33);

  // ── BRAND ACCENT ─────────────────────────────────────────
  /// Primary teal accent — main AR colour, CTAs, active states
  static const Color teal = Color(0xFF00D2B4);

  /// Secondary blue accent — gradients, tools, info
  static const Color blue = Color(0xFF0077FF);

  // ── CATEGORY / DEVICE ACCENTS ────────────────────────────
  /// Bike / orange category accent
  static const Color orange = Color(0xFFFF6B35);

  /// Phone / purple category accent
  static const Color purple = Color(0xFF9B59B6);

  /// TV / red category accent
  static const Color red = Color(0xFFE74C3C);

  /// Google brand blue (Google sign-in button)
  static const Color googleBlue = Color(0xFF4285F4);

  // ── SEMANTIC / STATUS ────────────────────────────────────
  /// Success / "Done" status
  static const Color success = Color(0xFF27C568);

  /// Warning / "In progress" status — also used for safety notes
  static const Color warning = Color(0xFFFF9500);

  /// Danger / "Sign out" / hard difficulty
  static const Color danger = Color(0xFFE74C3C);

  // ── UTILITY ──────────────────────────────────────────────
  /// Gold star rating colour
  static const Color star = Color(0xFFFFD700);

  // ── WHITE OPACITIES (common semi-transparent whites) ─────
  static Color white4   = Colors.white.withOpacity(0.04);
  static Color white5   = Colors.white.withOpacity(0.05);
  static Color white6   = Colors.white.withOpacity(0.06);
  static Color white7   = Colors.white.withOpacity(0.07);
  static Color white8   = Colors.white.withOpacity(0.08);
  static Color white10  = Colors.white.withOpacity(0.10);
  static Color white12  = Colors.white.withOpacity(0.12);
  static Color white20  = Colors.white.withOpacity(0.20);
  static Color white25  = Colors.white.withOpacity(0.25);
  static Color white30  = Colors.white.withOpacity(0.30);
  static Color white35  = Colors.white.withOpacity(0.35);
  static Color white40  = Colors.white.withOpacity(0.40);
  static Color white45  = Colors.white.withOpacity(0.45);
  static Color white50  = Colors.white.withOpacity(0.50);
  static Color white60  = Colors.white.withOpacity(0.60);
  static Color white75  = Colors.white.withOpacity(0.75);

  // ── ILLUSTRATION-ONLY COLORS (onboarding panels) ────────
  /// Dark navy — device box in Point & Detect illustration
  static const Color illustrationDevice = Color(0xFF1C2A3E);

  /// Near-black — camera frame background in Voice Guided illustration
  static const Color illustrationCamera = Color(0xFF030810);

  /// Dark slate — target object inside camera frame
  static const Color illustrationTarget = Color(0xFF1A2535);
}

// ────────────────────────────────────────────────────────────
//  Gradients
// ────────────────────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  /// Primary brand gradient (teal → blue) — buttons, icons, FAB
  static const LinearGradient brand = LinearGradient(
    colors: [AppColors.teal, AppColors.blue],
  );

  /// Brand gradient with custom direction (top-left → bottom-right)
  static const LinearGradient brandDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.teal, AppColors.blue],
  );

  /// Scan banner background
  static const LinearGradient scanBanner = LinearGradient(
    colors: [AppColors.bannerStart, AppColors.bannerEnd],
  );

  /// Camera top-bar fade (black → transparent)
  static LinearGradient cameraTopFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
  );

  /// Camera bottom-bar fade (transparent → black)
  static LinearGradient cameraBottomFade = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Colors.black.withOpacity(0.85), Colors.transparent],
  );
}

// ────────────────────────────────────────────────────────────
//  Border Radii  (optional — handy for consistency)
// ────────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double xs  = 5.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 14.0;
  static const double xl  = 16.0;
  static const double xxl = 20.0;
  static const double card = 18.0;
  static const double sheet = 32.0;
}