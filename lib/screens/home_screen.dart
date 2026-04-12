import 'package:fix_ar/constants/constant.dart';
import 'package:fix_ar/screens/profile_screen.dart';
import 'package:fix_ar/screens/setting_screen.dart';
import 'package:fix_ar/screens/tutorial_screen.dart';
import 'package:fix_ar/widgets/feature_cards.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── MODELS (unchanged)
class RepairCategory {
  final String label;
  final Color color;
  const RepairCategory({required this.label, required this.color});
}

class FeaturedTutorial {
  final String tag, title, views, difficulty;
  final Color accentColor;
  final IconData icon;
  const FeaturedTutorial({
    required this.tag, required this.title, required this.views,
    required this.difficulty, required this.accentColor, required this.icon,
  });
}

class RecentRepair {
  final String deviceName, subtitle, status;
  final Color accentColor;
  final IconData icon;
  const RecentRepair({
    required this.deviceName, required this.subtitle, required this.status,
    required this.icon, required this.accentColor,
  });
}

// ── STATIC DATA (unchanged)
const List<RepairCategory> repairCategories = [
  RepairCategory(label: 'All',    color: AppColors.teal),
  RepairCategory(label: 'Router', color: AppColors.teal),
  RepairCategory(label: 'PC',     color: AppColors.blue),
  RepairCategory(label: 'Bike',   color: AppColors.orange),
  RepairCategory(label: 'Phone',  color: AppColors.purple),
  RepairCategory(label: 'TV',     color: AppColors.red),
];

const List<FeaturedTutorial> featuredTutorials = [
  FeaturedTutorial(tag: 'Router', title: 'Antenna signal boost',
      views: '12.4k views', difficulty: 'Easy',
      accentColor: AppColors.teal, icon: Icons.router_rounded),
  FeaturedTutorial(tag: 'PC', title: 'GPU replacement guide',
      views: '8.1k views', difficulty: 'Med',
      accentColor: AppColors.blue, icon: Icons.memory_rounded),
  FeaturedTutorial(tag: 'Bike', title: 'Brake cable repair',
      views: '5.6k views', difficulty: 'Easy',
      accentColor: AppColors.orange, icon: Icons.pedal_bike_rounded),
  FeaturedTutorial(tag: 'Phone', title: 'Screen replacement',
      views: '20.1k views', difficulty: 'Hard',
      accentColor: AppColors.purple, icon: Icons.smartphone_rounded),
];

const List<RecentRepair> recentRepairs = [
  RecentRepair(deviceName: 'TP-Link Router', subtitle: 'Step 3 of 7 · 2h ago',
      status: 'In progress', accentColor: AppColors.teal, icon: Icons.router_rounded),
  RecentRepair(deviceName: 'Dell Laptop Fan', subtitle: 'Completed · Yesterday',
      status: 'Done', accentColor: AppColors.blue, icon: Icons.laptop_rounded),
  RecentRepair(deviceName: 'Shimano Gear', subtitle: 'Paused · 3 days ago',
      status: 'Paused', accentColor: AppColors.orange, icon: Icons.pedal_bike_rounded),
];

// ── SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _selectedNav = 0;

  // ── NAV TAP — center FAB (index 2) pushes AR camera
  void _onNavTap(int index) {
    setState(() => _selectedNav = index);
  }

  // ── ALL 4 SCREENS for IndexedStack
  List<Widget> get _screens => [
    _homeContent(),                          // 0 — Home
    const TutorialScreen(showNav: false),    // 1 — Tutorials
    const ProfileScreen(showNav: false),     // 2 — Profile
    const SettingsScreen(showNav: false),    // 3 — Settings
  ];

  // ── COLOR HELPERS
  Color _statusColor(String status) => switch (status) {
    'Done'        => AppColors.success,
    'In progress' => AppColors.teal,
    'Paused'      => AppColors.warning,
    _             => Colors.white,
  };

  Color _diffColor(String diff) => switch (diff) {
    'Easy' => AppColors.teal,
    'Med'  => Colors.orange,
    'Hard' => AppColors.red,
    _      => Colors.white38,
  };

  // ── BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            // ── IndexedStack switches content, nav stays fixed
            Expanded(
              child: IndexedStack(
                index: _selectedNav,
                children: _screens,
              ),
            ),

            // ── Fixed bottom nav always visible
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── HOME CONTENT (extracted so IndexedStack can hold it)
  Widget _homeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildScanBanner(),
          _buildSectionHeader('Categories', 'See all'),
          _buildCategoryChips(),
          _buildSectionHeader('Featured', 'See all'),
          _buildFeaturedCards(),
          _buildSectionHeader('Recent repairs', 'History'),
          _buildRecentRepairs(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning,', style: GoogleFonts.dmSans(
                fontSize: 14, color: Colors.white.withOpacity(0.35),
              )),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(children: [
                  TextSpan(text: 'Fix', style: GoogleFonts.syne(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: -0.5,
                  )),
                  TextSpan(text: 'AR', style: GoogleFonts.syne(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: AppColors.teal, letterSpacing: -0.5,
                  )),
                ]),
              ),
            ],
          ),
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppColors.teal, AppColors.blue],
              ),
            ),
            child: Center(child: Text('KK', style: GoogleFonts.syne(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
            ))),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3), size: 18),
            const SizedBox(width: 10),
            Text('Search repairs, parts, guides...', style: GoogleFonts.dmSans(
              fontSize: 13, color: Colors.white.withOpacity(0.25),
            )),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(right: 10),
              width: 28, height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Icon(Icons.tune_rounded,
                  color: Colors.white.withOpacity(0.25), size: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/ar-camera'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.bannerStart, AppColors.bannerEnd],
            ),
            border: Border.all(color: AppColors.teal.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.teal, AppColors.blue],
                  ),
                ),
                child: const Icon(Icons.document_scanner_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scan a device', style: GoogleFonts.syne(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
                  )),
                  const SizedBox(height: 3),
                  Text('Point camera to detect & repair', style: GoogleFonts.dmSans(
                    fontSize: 11, color: Colors.white.withOpacity(0.35),
                  )),
                ],
              )),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.teal.withOpacity(0.35)),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.teal, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.syne(
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
          )),
          Text(action, style: GoogleFonts.dmSans(
            fontSize: 12, color: AppColors.teal,
          )),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: repairCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final cat = repairCategories[index];
          final isActive = index == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isActive
                    ? cat.color.withOpacity(0.12)
                    : Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: isActive
                      ? cat.color.withOpacity(0.4)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? cat.color : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(cat.label, style: GoogleFonts.dmSans(
                    fontSize: 12, fontWeight: FontWeight.w500,
                    color: isActive ? cat.color : Colors.white.withOpacity(0.45),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCards() {
    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: featuredTutorials.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final t = featuredTutorials[index];
          return FeaturedCard(tutorial: t, diffColor: _diffColor(t.difficulty));
        },
      ),
    );
  }

  Widget _buildRecentRepairs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: recentRepairs.map((repair) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RecentRepairItem(
            repair: repair,
            statusColor: _statusColor(repair.status),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(
          color: Colors.white.withOpacity(0.06), width: 1,
        )),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(icon: Icons.home_rounded, label: 'Home',
              isActive: _selectedNav == 0, onTap: () => _onNavTap(0)),
          NavItem(icon: Icons.menu_book_rounded, label: 'Tutorials',
              isActive: _selectedNav == 1, onTap: () => _onNavTap(1)),

          // Center Scan FAB — pushes over nav, doesn't switch index
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/ar-camera'),
            child: Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: AppGradients.brandDiagonal,
              ),
              child: const Icon(Icons.document_scanner_rounded,
                  color: Colors.white, size: 24),
            ),
          ),

          NavItem(icon: Icons.person_rounded, label: 'Profile',
              isActive: _selectedNav == 2, onTap: () => _onNavTap(2)),
          NavItem(icon: Icons.settings_rounded, label: 'Settings',
              isActive: _selectedNav == 3, onTap: () => _onNavTap(3)),
        ],
      ),
    );
  }
}