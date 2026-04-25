import 'package:fix_ar/screens/home/bloc/home_bloc.dart';
import 'package:fix_ar/screens/home/bloc/home_event.dart';
import 'package:fix_ar/screens/home/bloc/home_state.dart';
import 'package:fix_ar/screens/profile/profile_screen.dart';
import 'package:fix_ar/screens/setting_screen.dart';
import 'package:fix_ar/screens/tutorial_screen.dart';
import 'package:fix_ar/widgets/feature_cards.dart';
import 'package:fix_ar/widgets/app_widgets.dart';
import 'package:fix_ar/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

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
    required this.tag,
    required this.title,
    required this.views,
    required this.difficulty,
    required this.accentColor,
    required this.icon,
  });
}

class RecentRepair {
  final String deviceName, subtitle, status;
  final Color accentColor;
  final IconData icon;
  const RecentRepair({
    required this.deviceName,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.accentColor,
  });
}

const List<RepairCategory> repairCategories = [
  RepairCategory(label: 'All', color: AppColors.teal),
  RepairCategory(label: 'Router', color: AppColors.teal),
  RepairCategory(label: 'PC', color: AppColors.blue),
  RepairCategory(label: 'Bike', color: AppColors.orange),
  RepairCategory(label: 'Phone', color: AppColors.purple),
  RepairCategory(label: 'TV', color: AppColors.red),
];

const List<FeaturedTutorial> featuredTutorials = [
  FeaturedTutorial(
    tag: 'Router',
    title: 'Antenna signal boost',
    views: '12.4k views',
    difficulty: 'Easy',
    accentColor: AppColors.teal,
    icon: Icons.router_rounded,
  ),
  FeaturedTutorial(
    tag: 'PC',
    title: 'GPU replacement guide',
    views: '8.1k views',
    difficulty: 'Med',
    accentColor: AppColors.blue,
    icon: Icons.memory_rounded,
  ),
  FeaturedTutorial(
    tag: 'Bike',
    title: 'Brake cable repair',
    views: '5.6k views',
    difficulty: 'Easy',
    accentColor: AppColors.orange,
    icon: Icons.pedal_bike_rounded,
  ),
  FeaturedTutorial(
    tag: 'Phone',
    title: 'Screen replacement',
    views: '20.1k views',
    difficulty: 'Hard',
    accentColor: AppColors.purple,
    icon: Icons.smartphone_rounded,
  ),
];

const List<RecentRepair> recentRepairs = [
  RecentRepair(
    deviceName: 'TP-Link Router',
    subtitle: 'Step 3 of 7 · 2h ago',
    status: 'In progress',
    accentColor: AppColors.teal,
    icon: Icons.router_rounded,
  ),
  RecentRepair(
    deviceName: 'Dell Laptop Fan',
    subtitle: 'Completed · Yesterday',
    status: 'Done',
    accentColor: AppColors.blue,
    icon: Icons.laptop_rounded,
  ),
  RecentRepair(
    deviceName: 'Shimano Gear',
    subtitle: 'Paused · 3 days ago',
    status: 'Paused',
    accentColor: AppColors.orange,
    icon: Icons.pedal_bike_rounded,
  ),
];

Color _statusColor(String s) => switch (s) {
  'Done' => AppColors.success,
  'In progress' => AppColors.teal,
  'Paused' => AppColors.warning,
  _ => Colors.white,
};
Color _diffColor(String d) => switch (d) {
  'Easy' => AppColors.teal,
  'Med' => AppColors.warning,
  'Hard' => AppColors.danger,
  _ => Colors.white38,
};

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => HomeBloc(), child: const _HomeView());
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  List<Widget> _screens(BuildContext context) => [
    const _HomeContent(),
    const TutorialScreen(showNav: false),
    const ProfileScreen(showNav: false),
    const SettingsScreen(showNav: false),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: state.selectedNav,
                  children: _screens(context),
                ),
              ),
              _BottomNav(selectedNav: state.selectedNav),
            ],
          ),
        ),
      ),
    );
  }
}

// ── HOME CONTENT
class _HomeContent extends StatelessWidget {
  const _HomeContent();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, n) => p.isLoading != n.isLoading,
      builder: (_, state) => state.isLoading
          ? const _HomeShimmer()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const _SearchBar(),
                  const _ScanBanner(),
                  AppSectionHeader(title: 'Categories', action: 'See all'),
                  const _CategoryChips(),
                  AppSectionHeader(title: 'Featured', action: 'See all'),
                  const _FeaturedCards(),
                  AppSectionHeader(title: 'Recent repairs', action: 'History'),
                  const _RecentRepairs(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  static Widget _box(double w, double h, {double r = 10}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(r),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1A2E),
      highlightColor: const Color(0xFF2A2A3E),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(90, 12),
                    const SizedBox(height: 8),
                    _box(120, 22, r: 6),
                  ],
                ),
                _box(42, 42, r: 21),
              ],
            ),
            const SizedBox(height: 20),

            // Search bar
            _box(sw - 40, 46, r: 14),
            const SizedBox(height: 16),

            // Scan banner
            _box(sw - 40, 78, r: 20),
            const SizedBox(height: 24),

            // Section label
            _box(100, 14, r: 6),
            const SizedBox(height: 14),

            // Category chips
            Row(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _box(70, 34, r: 20),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section label
            _box(80, 14, r: 6),
            const SizedBox(height: 14),

            // Featured cards
            Row(
              children: List.generate(
                2,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _box(160, 178, r: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section label
            _box(110, 14, r: 6),
            const SizedBox(height: 14),

            // Recent repair rows
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    _box(44, 44, r: 13),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(140, 13, r: 6),
                        const SizedBox(height: 7),
                        _box(100, 11, r: 5),
                      ],
                    ),
                    const Spacer(),
                    _box(64, 26, r: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.white35),
            ),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Fix',
                    style: GoogleFonts.syne(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'AR',
                    style: GoogleFonts.syne(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.brandDiagonal,
          ),
          child: Center(
            child: Text(
              'KK',
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.white5,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: AppColors.white30, size: 18),
          const SizedBox(width: 10),
          Text(
            'Search repairs, parts, guides...',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.white25),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.white5,
            ),
            child: Icon(Icons.tune_rounded, color: AppColors.white25, size: 15),
          ),
        ],
      ),
    ),
  );
}

class _ScanBanner extends StatelessWidget {
  const _ScanBanner();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/ar-camera'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppGradients.scanBanner,
          border: Border.all(color: AppColors.teal.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: AppGradients.brandDiagonal,
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan a device',
                    style: GoogleFonts.syne(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Point camera to detect & repair',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.white35,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.teal.withOpacity(0.35)),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.teal,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, n) => p.selectedCategory != n.selectedCategory,
      builder: (_, state) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: repairCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = repairCategories[i];
            final active = i == state.selectedCategory;
            return GestureDetector(
              onTap: () => bloc.add(HomeCategoryChanged(i)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: active
                      ? cat.color.withOpacity(0.12)
                      : AppColors.white4,
                  border: Border.all(
                    color: active
                        ? cat.color.withOpacity(0.4)
                        : AppColors.white8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? cat.color : AppColors.white20,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: active ? cat.color : AppColors.white45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeaturedCards extends StatelessWidget {
  const _FeaturedCards();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 178,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: featuredTutorials.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final t = featuredTutorials[i];
        return FeaturedCard(tutorial: t, diffColor: _diffColor(t.difficulty));
      },
    ),
  );
}

class _RecentRepairs extends StatelessWidget {
  const _RecentRepairs();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: recentRepairs
          .map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RecentRepairItem(
                repair: r,
                statusColor: _statusColor(r.status),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _BottomNav extends StatelessWidget {
  final int selectedNav;
  const _BottomNav({required this.selectedNav});
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.white6)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: selectedNav == 0,
            onTap: () => bloc.add(HomeNavChanged(0)),
          ),
          NavItem(
            icon: Icons.menu_book_rounded,
            label: 'Tutorials',
            isActive: selectedNav == 1,
            onTap: () => bloc.add(HomeNavChanged(1)),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/ar-camera'),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: AppGradients.brandDiagonal,
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            isActive: selectedNav == 2,
            onTap: () => bloc.add(HomeNavChanged(2)),
          ),
          NavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isActive: selectedNav == 3,
            onTap: () => bloc.add(HomeNavChanged(3)),
          ),
        ],
      ),
    );
  }
}
