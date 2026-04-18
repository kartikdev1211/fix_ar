import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_ar/constants/constant.dart';

// ════════════════════════════════════════════════════════════
//  FixAR — Reusable Stateless Widgets
// ════════════════════════════════════════════════════════════

// ── 1. APP ICON BOX
// Rounded container with a colored icon and tinted background.
// Used in: home banner, repair cards, parts cards, profile tiles, result card, etc.
class AppIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double radius;
  final bool bordered;

  const AppIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 20,
    this.radius = 12,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: color.withOpacity(0.1),
        border: bordered
            ? Border.all(color: color.withOpacity(0.25))
            : null,
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

// ── 2. APP CHIP
// Small label badge/pill with tinted background.
// Used in: category tags, difficulty badges, condition labels, status badges.
class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;
  final EdgeInsets padding;
  final double radius;
  final bool bordered;

  const AppChip({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    this.radius = 6,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: color.withOpacity(0.1),
        border: bordered ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── 3. APP GRADIENT BUTTON
// Full-width gradient CTA button.
// Used in: auth submit, onboarding CTA, repair complete, result card actions, permission retry.
class AppGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final double radius;
  final double fontSize;
  final bool isLoading;
  final Widget? leading;

  const AppGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 52,
    this.radius = 16,
    this.fontSize = 15,
    this.isLoading = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: isLoading ? null : AppGradients.brand,
          color: isLoading ? AppColors.white6 : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.teal,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[leading!, const SizedBox(width: 8)],
                    Text(
                      label,
                      style: GoogleFonts.syne(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── 4. APP OUTLINE BUTTON
// Full-width ghost/outline button.
// Used in: repair nav (prev/next), result card secondary action, out-of-stock parts.
class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final double radius;
  final double fontSize;
  final Color? labelColor;
  final Widget? leading;
  final Widget? trailing;

  const AppOutlineButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 44,
    this.radius = 12,
    this.fontSize = 13,
    this.labelColor,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? AppColors.white60;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: AppColors.white4,
          border: Border.all(color: AppColors.white8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: fontSize,
                color: onTap != null ? color : AppColors.white25,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          ],
        ),
      ),
    );
  }
}

// ── 5. APP FILTER CHIP
// Single animated filter pill for horizontal chip rows.
// Used in: home categories, tutorial filter, parts filter, camera modes.
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;
  final double fontSize;
  final EdgeInsets padding;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.teal;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive ? color.withOpacity(0.12) : AppColors.white4,
          border: Border.all(
            color: isActive ? color.withOpacity(0.4) : AppColors.white8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: isActive ? color : AppColors.white40,
          ),
        ),
      ),
    );
  }
}

// ── 6. APP SECTION HEADER
// Title + trailing action text row.
// Used in: home screen section headers (Categories, Featured, Recent repairs).
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.syne(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.teal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 7. APP BACK BUTTON
// Standard 36×36 rounded back icon button.
// Used in: parts screen, repair screen, camera screen top bar.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;

  const AppBackButton({super.key, this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: AppIconButton(
        icon: Icons.arrow_back_ios_rounded,
        iconColor: iconColor ?? Colors.white,
        iconSize: 16,
      ),
    );
  }
}

// ── 8. APP ICON BUTTON
// Generic 36×36 rounded icon button with tinted or plain background.
// Used in: all screen top bars (search, tune, mic, settings icon, etc.)
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double size;
  final double iconSize;
  final double radius;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.size = 36,
    this.iconSize = 18,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: backgroundColor ?? AppColors.white5,
          border: Border.all(color: borderColor ?? AppColors.white8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.white40,
          size: iconSize,
        ),
      ),
    );
  }
}

// ── 9. APP SAFETY WARNING
// Orange warning banner with icon + text.
// Used in: repair steps, parts cards.
class AppSafetyWarning extends StatelessWidget {
  final String text;
  final EdgeInsets padding;

  const AppSafetyWarning({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.warning.withOpacity(0.08),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.warning.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 10. APP GLOW BACKGROUND
// Radial glow blob for atmospheric background effect.
// Used in: splash screen, auth screen.
class AppGlowBackground extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  final Alignment alignment;

  const AppGlowBackground({
    super.key,
    required this.color,
    this.size = 280,
    this.opacity = 0.1,
    this.alignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }
}
