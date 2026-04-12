import 'package:fix_ar/constants/constant.dart';
import 'package:fix_ar/widgets/bracket_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanControlller;
  late Animation<double> _scanAnim;
  late AnimationController _loaderController;
  late Animation<double> _loaderAnim;
  late AnimationController _ringController;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    _initAnim();
    _navigateAfterDelay();
    super.initState();
  }

  void _initAnim() {
    _scanControlller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(_scanControlller);
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _loaderAnim = Tween<double>(begin: 0.2, end: 0.85).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeInOut),
    );
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _ringAnim = CurvedAnimation(parent: _ringController, curve: Curves.easeOut);
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/onboarding");
      }
    });
  }

  @override
  void dispose() {
    _scanControlller.dispose();
    _loaderController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: size.height * 0.18,
            left: size.width * 0.5 - 130,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.teal.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _ringAnim,
              child: Stack(
                children: [_buildRing(180, 0.12), _buildRing(240, 0.06)],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (context, _) {
              return Positioned(
                top: size.height * _scanAnim.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.teal.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ..._buildCornerBrackets(size),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppGradients.brandDiagonal,
                  ),
                  child: const Icon(Icons.build_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  "FixAR",
                  style: GoogleFonts.syne(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AR REPAIR ASSISTANT',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.teal.withOpacity(0.8),
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 48),
                AnimatedBuilder(
                  animation: _loaderAnim,
                  builder: (context, _) {
                    return Container(
                      width: 56,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.white8,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _loaderAnim.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: AppGradients.brand,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(double size, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.teal.withOpacity(opacity), width: 1),
      ),
    );
  }

  List<Widget> _buildCornerBrackets(Size size) {
    const color = AppColors.teal;
    const opacity = 0.5;
    const bSize = 22.0;
    const bWidth = 1.5;
    const padding = 20.0;

    Widget bracket({
      required Alignment align,
      bool top = false, bool bottom = false,
      bool left = false, bool right = false,
    }) {
      return Positioned(
        top: top ? padding + 40 : null,
        bottom: bottom ? padding : null,
        left: left ? padding : null,
        right: right ? padding : null,
        child: SizedBox(
          width: bSize, height: bSize,
          child: CustomPaint(
            painter: BracketPainter(
              color: color.withOpacity(opacity),
              strokeWidth: bWidth,
              showTop: top, showBottom: bottom,
              showLeft: left, showRight: right,
            ),
          ),
        ),
      );
    }

    return [
      bracket(align: Alignment.topLeft, top: true, left: true),
      bracket(align: Alignment.topRight, top: true, right: true),
      bracket(align: Alignment.bottomLeft, bottom: true, left: true),
      bracket(align: Alignment.bottomRight, bottom: true, right: true),
    ];
  }
}