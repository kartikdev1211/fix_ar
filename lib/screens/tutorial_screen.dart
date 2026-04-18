import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_ar/constants/constant.dart';
import 'package:fix_ar/widgets/app_widgets.dart';

class Tutorial {
  final String title, category, author, duration, difficulty;
  final int views;
  final IconData icon;
  final Color accent;

  const Tutorial({
    required this.title, required this.category, required this.author,
    required this.duration, required this.difficulty, required this.views,
    required this.icon, required this.accent,
  });
}

const _tutorials = [
  Tutorial(title: 'Antenna signal boost', category: 'Router', author: 'techfix_pro',
      duration: '8 min', difficulty: 'Easy', views: 12400,
      icon: Icons.router_rounded, accent: AppColors.teal),
  Tutorial(title: 'GPU replacement guide', category: 'PC', author: 'hardwarehero',
      duration: '22 min', difficulty: 'Med', views: 8100,
      icon: Icons.memory_rounded, accent: AppColors.blue),
  Tutorial(title: 'Brake cable repair', category: 'Bike', author: 'bikewrench',
      duration: '12 min', difficulty: 'Easy', views: 5600,
      icon: Icons.pedal_bike_rounded, accent: AppColors.orange),
  Tutorial(title: 'Screen replacement', category: 'Phone', author: 'phonelab',
      duration: '18 min', difficulty: 'Hard', views: 20100,
      icon: Icons.smartphone_rounded, accent: AppColors.purple),
  Tutorial(title: 'RAM upgrade guide', category: 'PC', author: 'pcmaster',
      duration: '10 min', difficulty: 'Easy', views: 9300,
      icon: Icons.memory_rounded, accent: AppColors.blue),
  Tutorial(title: 'Chain lubrication', category: 'Bike', author: 'bikewrench',
      duration: '5 min', difficulty: 'Easy', views: 3200,
      icon: Icons.pedal_bike_rounded, accent: AppColors.orange),
];

const _filters = ['All', 'Router', 'PC', 'Bike', 'Phone'];

class TutorialScreen extends StatefulWidget {
  final bool showNav;
  const TutorialScreen({super.key, this.showNav = true});
  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _filter = 0;

  List<Tutorial> get _filtered => _filter == 0
      ? _tutorials
      : _tutorials.where((t) => t.category == _filters[_filter]).toList();

  Color _diffColor(String d) => switch (d) {
    'Easy' => AppColors.teal,
    'Med'  => AppColors.warning,
    _      => AppColors.danger,
  };

  String _formatViews(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Tutorials', style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
              AppIconButton(icon: Icons.search_outlined, iconSize: 18),
            ]),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => AppFilterChip(
                label: _filters[i], isActive: i == _filter,
                onTap: () => setState(() => _filter = i),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text('${_filtered.length} guides found',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.white30)),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _TutorialTile(
                tutorial: _filtered[i],
                diffColor: _diffColor(_filtered[i].difficulty),
                formatViews: _formatViews,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TutorialTile extends StatelessWidget {
  final Tutorial tutorial;
  final Color diffColor;
  final String Function(int) formatViews;

  const _TutorialTile({required this.tutorial, required this.diffColor, required this.formatViews});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), color: AppColors.white4,
        border: Border.all(color: AppColors.white7),
      ),
      child: Row(children: [
        AppIconBox(icon: tutorial.icon, color: tutorial.accent, size: 52, radius: 14, bordered: true),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AppChip(label: tutorial.category, color: tutorial.accent,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), fontSize: 9),
            const SizedBox(width: 6),
            AppChip(label: tutorial.difficulty, color: diffColor,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), fontSize: 9),
          ]),
          const SizedBox(height: 5),
          Text(tutorial.title, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.person_outline_rounded, size: 11, color: AppColors.white25),
            const SizedBox(width: 3),
            Text(tutorial.author, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.white25)),
            const SizedBox(width: 10),
            Icon(Icons.timer_outlined, size: 11, color: AppColors.white25),
            const SizedBox(width: 3),
            Text(tutorial.duration, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.white25)),
            const SizedBox(width: 10),
            Icon(Icons.remove_red_eye_outlined, size: 11, color: AppColors.white25),
            const SizedBox(width: 3),
            Text(formatViews(tutorial.views), style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.white25)),
          ]),
        ])),
        Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.white20),
      ]),
    );
  }
}
