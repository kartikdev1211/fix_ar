import 'package:fix_ar/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final bool showNav;
  const ProfileScreen({super.key, this.showNav = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsRow(),
            _buildSectionTitle('Repair History'),
            _buildRepairHistory(),
            _buildSectionTitle('Saved Guides'),
            _buildSavedGuides(),
            _buildSectionTitle('Achievements'),
            _buildAchievements(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── HEADER — avatar + name + level badge
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Column(
        children: [

          // Avatar
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.teal, AppColors.blue],
              ),
            ),
            child: Center(child: Text('KK', style: GoogleFonts.syne(
              fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
            ))),
          ),

          const SizedBox(height: 12),

          // Name
          Text('Kartik Kumar', style: GoogleFonts.syne(
            fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
          )),

          const SizedBox(height: 4),

          // Email
          Text('kartik@fixar.app', style: GoogleFonts.dmSans(
            fontSize: 12, color: Colors.white.withOpacity(0.35),
          )),

          const SizedBox(height: 12),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.teal.withOpacity(0.12),
              border: Border.all(
                color: AppColors.teal.withOpacity(0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded,
                    color: AppColors.teal, size: 14),
                const SizedBox(width: 4),
                Text('Pro Fixer · Level 7', style: GoogleFonts.dmSans(
                  fontSize: 11, fontWeight: FontWeight.w500,
                  color: AppColors.teal,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS ROW — repairs, guides, hours
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          _StatCard(value: '24', label: 'Repairs'),
          const SizedBox(width: 10),
          _StatCard(value: '12', label: 'Saved'),
          const SizedBox(width: 10),
          _StatCard(value: '38h', label: 'Time saved'),
        ],
      ),
    );
  }

  // ── REPAIR HISTORY
  Widget _buildRepairHistory() {
    const history = [
      _RepairEntry(
        icon: Icons.router_rounded,
        name: 'TP-Link Router',
        date: 'Today · Step 3 of 7',
        status: 'In progress',
        accent: AppColors.teal,
      ),
      _RepairEntry(
        icon: Icons.laptop_rounded,
        name: 'Dell Laptop Fan',
        date: 'Yesterday',
        status: 'Done',
        accent: AppColors.blue,
      ),
      _RepairEntry(
        icon: Icons.pedal_bike_rounded,
        name: 'Shimano Gear',
        date: '3 days ago',
        status: 'Paused',
        accent: AppColors.orange,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: history.map((e) => _buildRepairTile(e)).toList(),
      ),
    );
  }

  Widget _buildRepairTile(_RepairEntry e) {
    final statusColor = switch (e.status) {
      'Done'        => AppColors.success,
      'In progress' => AppColors.teal,
      _             => AppColors.warning,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: e.accent.withOpacity(0.1),
            ),
            child: Icon(e.icon, color: e.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.name, style: GoogleFonts.syne(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
              )),
              const SizedBox(height: 2),
              Text(e.date, style: GoogleFonts.dmSans(
                fontSize: 10, color: Colors.white.withOpacity(0.3),
              )),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: statusColor.withOpacity(0.1),
            ),
            child: Text(e.status, style: GoogleFonts.dmSans(
              fontSize: 10, fontWeight: FontWeight.w500, color: statusColor,
            )),
          ),
        ],
      ),
    );
  }

  // ── SAVED GUIDES
  Widget _buildSavedGuides() {
    const guides = [
      _SavedGuide(icon: Icons.memory_rounded,
          title: 'GPU replacement guide', category: 'PC',
          accent: AppColors.blue),
      _SavedGuide(icon: Icons.smartphone_rounded,
          title: 'Screen replacement', category: 'Phone',
          accent: AppColors.purple),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: guides.map((g) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: g.accent.withOpacity(0.1),
                ),
                child: Icon(g.icon, color: g.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(g.title, style: GoogleFonts.syne(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
              ))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: g.accent.withOpacity(0.1),
                ),
                child: Text(g.category, style: GoogleFonts.dmSans(
                  fontSize: 10, color: g.accent, fontWeight: FontWeight.w500,
                )),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ── ACHIEVEMENTS
  Widget _buildAchievements() {
    const badges = [
      _Badge(icon: Icons.bolt_rounded,      label: 'First Fix',    color: AppColors.teal),
      _Badge(icon: Icons.local_fire_department_rounded, label: '5 Streak', color: AppColors.orange),
      _Badge(icon: Icons.star_rounded,      label: 'Top Fixer',    color: AppColors.star),
      _Badge(icon: Icons.verified_rounded,  label: 'Pro Level',    color: AppColors.blue),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        children: badges.map((b) => Expanded(
          child: Container(
            margin:  EdgeInsets.only(right: b == badges.last ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: b.color.withOpacity(0.07),
              border: Border.all(color: b.color.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(b.icon, color: b.color, size: 22),
                const SizedBox(height: 6),
                Text(b.label, style: GoogleFonts.dmSans(
                  fontSize: 9, color: b.color, fontWeight: FontWeight.w500,
                ), textAlign: TextAlign.center),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  // ── SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(title, style: GoogleFonts.syne(
        fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
      )),
    );
  }
}

// ── SMALL WIDGETS & DATA CLASSES

class _StatCard extends StatelessWidget {
  final String value, label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.syne(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: AppColors.teal,
            )),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.dmSans(
              fontSize: 10, color: Colors.white.withOpacity(0.35),
            )),
          ],
        ),
      ),
    );
  }
}

class _RepairEntry {
  final IconData icon;
  final String name, date, status;
  final Color accent;
  const _RepairEntry({
    required this.icon, required this.name,
    required this.date, required this.status, required this.accent,
  });
}

class _SavedGuide {
  final IconData icon;
  final String title, category;
  final Color accent;
  const _SavedGuide({
    required this.icon, required this.title,
    required this.category, required this.accent,
  });
}

class _Badge {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});
}