import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_ar/constants/constant.dart';
import 'package:fix_ar/widgets/app_widgets.dart';

class Part {
  final String name, brand, price, compatibility;
  final PartCondition condition;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final Color accent;
  final IconData icon;
  final bool hasSafetyNote;
  final String? safetyNote;

  const Part({
    required this.name, required this.brand, required this.price,
    required this.compatibility, required this.condition, required this.rating,
    required this.reviewCount, required this.inStock, required this.accent,
    required this.icon, this.hasSafetyNote = false, this.safetyNote,
  });
}

enum PartCondition { newPart, oemRefurbished, aftermarket }

const List<Part> routerParts = [
  Part(name: 'TP-Link Dual Band Antenna', brand: 'TP-Link Official', price: '₹349',
      compatibility: 'Archer C6, C7, C8', condition: PartCondition.newPart,
      rating: 4.7, reviewCount: 1240, inStock: true, accent: AppColors.teal,
      icon: Icons.settings_input_antenna_rounded),
  Part(name: 'Generic 5dBi WiFi Antenna', brand: 'AntennaPro', price: '₹199',
      compatibility: 'Universal SMA connector', condition: PartCondition.aftermarket,
      rating: 4.1, reviewCount: 580, inStock: true, accent: AppColors.blue,
      icon: Icons.settings_input_antenna_rounded, hasSafetyNote: true,
      safetyNote: 'Aftermarket antennas may exceed legal RF power limits in some regions.'),
  Part(name: 'OEM Refurbished Antenna Set', brand: 'ReFixParts', price: '₹249',
      compatibility: 'Archer C6 only', condition: PartCondition.oemRefurbished,
      rating: 4.4, reviewCount: 312, inStock: false, accent: AppColors.purple,
      icon: Icons.settings_input_antenna_rounded),
  Part(name: 'Router Power Board', brand: 'TP-Link Official', price: '₹599',
      compatibility: 'Archer C6 v2.0+', condition: PartCondition.newPart,
      rating: 4.8, reviewCount: 203, inStock: true, accent: AppColors.teal,
      icon: Icons.developer_board_rounded, hasSafetyNote: true,
      safetyNote: 'High voltage component. Discharge capacitors before handling.'),
];

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});
  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'New', 'OEM', 'Aftermarket'];

  List<Part> get _filtered {
    if (_selectedFilter == 0) return routerParts;
    final cond = [null, PartCondition.newPart, PartCondition.oemRefurbished, PartCondition.aftermarket][_selectedFilter];
    return routerParts.where((p) => p.condition == cond).toList();
  }

  String _conditionLabel(PartCondition c) => switch (c) {
    PartCondition.newPart        => 'New',
    PartCondition.oemRefurbished => 'OEM Refurb',
    PartCondition.aftermarket    => 'Aftermarket',
  };

  Color _conditionColor(PartCondition c) => switch (c) {
    PartCondition.newPart        => AppColors.teal,
    PartCondition.oemRefurbished => AppColors.purple,
    PartCondition.aftermarket    => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTopBar(),
          _buildDeviceInfo(),
          _buildFilters(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Text('${_filtered.length} parts found',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.white30)),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _PartCard(
                part: _filtered[i],
                conditionLabel: _conditionLabel(_filtered[i].condition),
                conditionColor: _conditionColor(_filtered[i].condition),
                onBuy: () => _showBuySheet(_filtered[i]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        AppBackButton(),
        Text('Parts & Spares', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        AppIconButton(icon: Icons.tune_rounded, iconSize: 18),
      ]),
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.teal.withOpacity(0.07),
        border: Border.all(color: AppColors.teal.withOpacity(0.2)),
      ),
      child: Row(children: [
        AppIconBox(icon: Icons.router_rounded, color: AppColors.teal, size: 40, radius: 11),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TP-Link Archer C6', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('Showing compatible parts only', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.white35)),
        ])),
        AppChip(label: '${routerParts.length} parts', color: AppColors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4)),
      ]),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => AppFilterChip(
          label: _filters[i], isActive: i == _selectedFilter,
          onTap: () => setState(() => _selectedFilter = i),
        ),
      ),
    );
  }

  void _showBuySheet(Part part) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: AppColors.white12)),
          const SizedBox(height: 20),
          Text('Buy from', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 16),
          _StoreOption(store: 'Amazon', price: part.price, delivery: '2-day delivery',
              color: AppColors.warning, onTap: () => Navigator.pop(context)),
          const SizedBox(height: 10),
          _StoreOption(store: 'Flipkart', price: part.price, delivery: '3-day delivery',
              color: AppColors.blue, onTap: () => Navigator.pop(context)),
          const SizedBox(height: 10),
          _StoreOption(store: 'Robu.in', price: '${part.price} + shipping', delivery: '5-7 days',
              color: AppColors.teal, onTap: () => Navigator.pop(context)),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  final Part part;
  final String conditionLabel;
  final Color conditionColor;
  final VoidCallback onBuy;

  const _PartCard({required this.part, required this.conditionLabel, required this.conditionColor, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: AppColors.white4, border: Border.all(color: AppColors.white7),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          AppIconBox(icon: part.icon, color: part.accent, size: 46, radius: 13, bordered: true),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(part.name, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
            const SizedBox(height: 3),
            Text(part.brand, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.white30)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(part.price, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 3),
            AppChip(label: conditionLabel, color: conditionColor,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), fontSize: 9),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.white25),
          const SizedBox(width: 5),
          Expanded(child: Text(part.compatibility, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.white30))),
          const Icon(Icons.star_rounded, color: AppColors.star, size: 12),
          const SizedBox(width: 3),
          Text('${part.rating} (${part.reviewCount})', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.white30)),
        ]),
        if (part.hasSafetyNote && part.safetyNote != null) ...[
          const SizedBox(height: 10),
          AppSafetyWarning(text: part.safetyNote!),
        ],
        const SizedBox(height: 12),
        GestureDetector(
          onTap: part.inStock ? onBuy : null,
          child: Container(
            width: double.infinity, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: part.inStock ? AppGradients.brand : null,
              color: part.inStock ? null : AppColors.white5,
              border: part.inStock ? null : Border.all(color: AppColors.white8),
            ),
            child: Center(child: Text(
              part.inStock ? 'Buy Now' : 'Out of Stock',
              style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700,
                  color: part.inStock ? Colors.white : AppColors.white25),
            )),
          ),
        ),
      ]),
    );
  }
}

class _StoreOption extends StatelessWidget {
  final String store, price, delivery;
  final Color color;
  final VoidCallback onTap;

  const _StoreOption({required this.store, required this.price, required this.delivery, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: AppColors.white4,
          border: Border.all(color: AppColors.white7),
        ),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color.withOpacity(0.12)),
            child: Center(child: Text(store[0], style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w800, color: color))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(store, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(delivery, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.white30)),
          ])),
          Text(price, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(width: 10),
          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.white20),
        ]),
      ),
    );
  }
}
