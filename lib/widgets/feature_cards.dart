// ── FEATURED CARD
import 'package:fix_ar/constants/constant.dart';
import 'package:fix_ar/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeaturedCard extends StatelessWidget {
  final FeaturedTutorial tutorial;
  final Color diffColor;

  const FeaturedCard({super.key, required this.tutorial, required this.diffColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.cardDark,
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Icon area
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: tutorial.accentColor.withOpacity(0.08),
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: tutorial.accentColor.withOpacity(0.12),
                  border: Border.all(
                    color: tutorial.accentColor.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  tutorial.icon,
                  color: tutorial.accentColor,
                  size: 22,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Tag
                Text(
                  tutorial.tag,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),

                const SizedBox(height: 3),

                // Title
                Text(
                  tutorial.title,
                  style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Views + difficulty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tutorial.views,
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: diffColor.withOpacity(0.12),
                      ),
                      child: Text(
                        tutorial.difficulty,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: diffColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}

// ── RECENT REPAIR ITEM
class RecentRepairItem extends StatelessWidget {
  final RecentRepair repair;
  final Color statusColor;

  const RecentRepairItem({super.key, required this.repair, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [

          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: repair.accentColor.withOpacity(0.1),
            ),
            child: Icon(
              repair.icon,
              color: repair.accentColor,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  repair.deviceName,
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  repair.subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: statusColor.withOpacity(0.1),
            ),
            child: Text(
              repair.status,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ── BOTTOM NAV ITEM
class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.teal
        : Colors.white.withOpacity(0.3);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          isActive
              ? Container(
            width: 4, height: 4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal,
            ),
          )
              : Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}