import 'package:fix_ar/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── DATA MODELS
class Part {
  final String name;
  final String brand;
  final String price;
  final String compatibility;
  final PartCondition condition;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final Color accent;
  final IconData icon;
  final bool hasSafetyNote;
  final String? safetyNote;

  const Part({
    required this.name,
    required this.brand,
    required this.price,
    required this.compatibility,
    required this.condition,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.accent,
    required this.icon,
    this.hasSafetyNote = false,
    this.safetyNote,
  });
}

enum PartCondition { newPart, oemRefurbished, aftermarket }

// ── STATIC DATA
const List<Part> routerParts = [
  Part(
    name: 'TP-Link Dual Band Antenna',
    brand: 'TP-Link Official',
    price: '₹349',
    compatibility: 'Archer C6, C7, C8',
    condition: PartCondition.newPart,
    rating: 4.7,
    reviewCount: 1240,
    inStock: true,
    accent: AppColors.teal,
    icon: Icons.settings_input_antenna_rounded,
  ),
  Part(
    name: 'Generic 5dBi WiFi Antenna',
    brand: 'AntennaPro',
    price: '₹199',
    compatibility: 'Universal SMA connector',
    condition: PartCondition.aftermarket,
    rating: 4.1,
    reviewCount: 580,
    inStock: true,
    accent: AppColors.blue,
    icon: Icons.settings_input_antenna_rounded,
    hasSafetyNote: true,
    safetyNote:
    'Aftermarket antennas may exceed legal RF power limits in some regions.',
  ),
  Part(
    name: 'OEM Refurbished Antenna Set',
    brand: 'ReFixParts',
    price: '₹249',
    compatibility: 'Archer C6 only',
    condition: PartCondition.oemRefurbished,
    rating: 4.4,
    reviewCount: 312,
    inStock: false,
    accent: AppColors.purple,
    icon: Icons.settings_input_antenna_rounded,
  ),
  Part(
    name: 'Router Power Board',
    brand: 'TP-Link Official',
    price: '₹599',
    compatibility: 'Archer C6 v2.0+',
    condition: PartCondition.newPart,
    rating: 4.8,
    reviewCount: 203,
    inStock: true,
    accent: AppColors.teal,
    icon: Icons.developer_board_rounded,
    hasSafetyNote: true,
    safetyNote:
    'High voltage component. Discharge capacitors before handling.',
  ),
];

// ── SCREEN
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
    final cond = [
      null,
      PartCondition.newPart,
      PartCondition.oemRefurbished,
      PartCondition.aftermarket,
    ][_selectedFilter];
    return routerParts.where((p) => p.condition == cond).toList();
  }

  String _conditionLabel(PartCondition c) => switch (c) {
    PartCondition.newPart       => 'New',
    PartCondition.oemRefurbished => 'OEM Refurb',
    PartCondition.aftermarket   => 'Aftermarket',
  };

  Color _conditionColor(PartCondition c) => switch (c) {
    PartCondition.newPart       => AppColors.teal,
    PartCondition.oemRefurbished => AppColors.purple,
    PartCondition.aftermarket   => Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildTopBar(),
            _buildDeviceInfo(),
            _buildFilters(),
            _buildResultCount(),

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
          ],
        ),
      ),
    );
  }

  // ── TOP BAR
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          Text('Parts & Spares', style: GoogleFonts.syne(
            fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
          )),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(Icons.tune_rounded,
                color: Colors.white.withOpacity(0.4), size: 18),
          ),
        ],
      ),
    );
  }

  // ── DEVICE INFO BANNER
  Widget _buildDeviceInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.teal.withOpacity(0.07),
        border: Border.all(
          color: AppColors.teal.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: AppColors.teal.withOpacity(0.12),
            ),
            child: const Icon(Icons.router_rounded,
                color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TP-Link Archer C6', style: GoogleFonts.syne(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
              )),
              Text('Showing compatible parts only',
                  style: GoogleFonts.dmSans(
                    fontSize: 10, color: Colors.white.withOpacity(0.35),
                  )),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.teal.withOpacity(0.12),
            ),
            child: Text('${routerParts.length} parts',
                style: GoogleFonts.dmSans(
                  fontSize: 10, fontWeight: FontWeight.w500,
                  color: AppColors.teal,
                )),
          ),
        ],
      ),
    );
  }

  // ── FILTER CHIPS
  Widget _buildFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: active
                    ? AppColors.teal.withOpacity(0.12)
                    : Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: active
                      ? AppColors.teal.withOpacity(0.4)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Text(_filters[i], style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: active
                    ? AppColors.teal
                    : Colors.white.withOpacity(0.4),
              )),
            ),
          );
        },
      ),
    );
  }

  // ── RESULT COUNT
  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Text('${_filtered.length} parts found',
          style: GoogleFonts.dmSans(
            fontSize: 11, color: Colors.white.withOpacity(0.3),
          )),
    );
  }

  // ── BUY BOTTOM SHEET
  void _showBuySheet(Part part) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withOpacity(0.12),
              ),
            ),

            const SizedBox(height: 20),

            Text('Buy from', style: GoogleFonts.syne(
              fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
            )),

            const SizedBox(height: 16),

            // Store options
            _StoreOption(
              store: 'Amazon',
              price: part.price,
              delivery: '2-day delivery',
              color: AppColors.warning,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            _StoreOption(
              store: 'Flipkart',
              price: part.price,
              delivery: '3-day delivery',
              color: AppColors.blue,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            _StoreOption(
              store: 'Robu.in',
              price: '${part.price} + shipping',
              delivery: '5-7 days',
              color: AppColors.teal,
              onTap: () => Navigator.pop(context),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── PART CARD
class _PartCard extends StatelessWidget {
  final Part part;
  final String conditionLabel;
  final Color conditionColor;
  final VoidCallback onBuy;

  const _PartCard({
    required this.part,
    required this.conditionLabel,
    required this.conditionColor,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── TOP ROW
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: part.accent.withOpacity(0.1),
                  border: Border.all(color: part.accent.withOpacity(0.2)),
                ),
                child: Icon(part.icon, color: part.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(part.name, style: GoogleFonts.syne(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: Colors.white, height: 1.2,
                    )),
                    const SizedBox(height: 3),
                    Text(part.brand, style: GoogleFonts.dmSans(
                      fontSize: 10, color: Colors.white.withOpacity(0.3),
                    )),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(part.price, style: GoogleFonts.syne(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: Colors.white,
                  )),
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: conditionColor.withOpacity(0.1),
                    ),
                    child: Text(conditionLabel, style: GoogleFonts.dmSans(
                      fontSize: 9, color: conditionColor,
                      fontWeight: FontWeight.w500,
                    )),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── COMPATIBILITY + RATING
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 12, color: Colors.white.withOpacity(0.25)),
              const SizedBox(width: 5),
              Expanded(child: Text(part.compatibility,
                  style: GoogleFonts.dmSans(
                    fontSize: 10, color: Colors.white.withOpacity(0.3),
                  ))),
              const Icon(Icons.star_rounded,
                  color: AppColors.star, size: 12),
              const SizedBox(width: 3),
              Text('${part.rating} (${part.reviewCount})',
                  style: GoogleFonts.dmSans(
                    fontSize: 10, color: Colors.white.withOpacity(0.3),
                  )),
            ],
          ),

          // ── SAFETY NOTE
          if (part.hasSafetyNote && part.safetyNote != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.orange.withOpacity(0.07),
                border: Border.all(
                    color: Colors.orange.withOpacity(0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 13),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(part.safetyNote!, style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: Colors.orange.withOpacity(0.85),
                      height: 1.5,
                    )),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── BUY BUTTON
          GestureDetector(
            onTap: part.inStock ? onBuy : null,
            child: Container(
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: part.inStock
                    ? AppGradients.brand
                    : null,
                color: part.inStock ? null : Colors.white.withOpacity(0.05),
                border: part.inStock
                    ? null
                    : Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Center(
                child: Text(
                  part.inStock ? 'Buy Now' : 'Out of Stock',
                  style: GoogleFonts.syne(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: part.inStock
                        ? Colors.white
                        : Colors.white.withOpacity(0.25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── STORE OPTION
class _StoreOption extends StatelessWidget {
  final String store, price, delivery;
  final Color color;
  final VoidCallback onTap;

  const _StoreOption({
    required this.store, required this.price,
    required this.delivery, required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color.withOpacity(0.12),
              ),
              child: Center(child: Text(store[0], style: GoogleFonts.syne(
                fontSize: 14, fontWeight: FontWeight.w800, color: color,
              ))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store, style: GoogleFonts.syne(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
                Text(delivery, style: GoogleFonts.dmSans(
                  fontSize: 10, color: Colors.white.withOpacity(0.3),
                )),
              ],
            )),
            Text(price, style: GoogleFonts.syne(
              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
            )),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}