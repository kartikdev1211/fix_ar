import 'package:fix_ar/screens/onboarding/onboarding_screen.dart';
import 'package:fix_ar/widgets/bracket_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingIllustrationPanel extends StatelessWidget {
  final OnboardingIllustration illustration;
  const OnboardingIllustrationPanel({super.key, required this.illustration});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: switch (illustration) {
        OnboardingIllustration.pointAndDetect =>
          const _PointDetectIllustration(),
        OnboardingIllustration.voiceGuided => const _VoiceGuidedIllustration(),
        OnboardingIllustration.community => const _CommunityIllustration(),
      },
    );
  }
}

class _PointDetectIllustration extends StatefulWidget {
  const _PointDetectIllustration();

  @override
  State<_PointDetectIllustration> createState() =>
      _PointDetectIllustrationState();
}

class _PointDetectIllustrationState extends State<_PointDetectIllustration>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnim;

  late AnimationController _labelController;
  late Animation<double> _labelFade;

  @override
  void initState() {
    super.initState();

    // Scanline sweeps repeatedly
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(_scanController);

    // Labels fade in once
    _labelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _labelFade = CurvedAnimation(
      parent: _labelController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final illustrationHeight = size.height * 0.55;

    return SizedBox(
      height: illustrationHeight,
      child: Stack(
        children: [
          // ── Background grid
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // ── Scanline
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (_, __) => Positioned(
              top: illustrationHeight * _scanAnim.value,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF00D2B4).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Device box (center)
          Center(
            child: Container(
              width: 160,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1C2A3E),
                border: Border.all(
                  color: const Color(0xFF0077FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: CustomPaint(painter: _MotherboardPainter()),
            ),
          ),

          // ── AR bracket corners around device
          Center(
            child: SizedBox(
              width: 176,
              height: 126,
              child: CustomPaint(painter: _ARBoxPainter()),
            ),
          ),

          // ── AR Label: CPU
          Positioned(
            top: illustrationHeight * 0.36,
            left: size.width * 0.62,
            child: FadeTransition(
              opacity: _labelFade,
              child: _ARLabel(label: 'CPU', color: const Color(0xFF00D2B4)),
            ),
          ),

          // ── AR Label: RAM
          Positioned(
            top: illustrationHeight * 0.48,
            left: size.width * 0.60,
            child: FadeTransition(
              opacity: _labelFade,
              child: _ARLabel(label: 'RAM', color: const Color(0xFF0077FF)),
            ),
          ),

          // ── AR Label: PSU
          Positioned(
            top: illustrationHeight * 0.38,
            right: size.width * 0.62,
            child: FadeTransition(
              opacity: _labelFade,
              child: _ARLabel(
                label: 'PSU',
                color: const Color(0xFF00D2B4),
                alignRight: true,
              ),
            ),
          ),

          // ── Corner AR brackets (screen edges)
          ..._screenBrackets(size, illustrationHeight),
        ],
      ),
    );
  }

  List<Widget> _screenBrackets(Size size, double h) {
    const c = Color(0xFF00D2B4);
    const op = 0.4;
    const s = 20.0;

    return [
      Positioned(
        top: 48,
        left: 20,
        child: _CornerBracket(size: s, color: c.withOpacity(op), topLeft: true),
      ),
      Positioned(
        top: 48,
        right: 20,
        child: _CornerBracket(
          size: s,
          color: c.withOpacity(op),
          topRight: true,
        ),
      ),
      Positioned(
        bottom: 0,
        left: 20,
        child: _CornerBracket(
          size: s,
          color: c.withOpacity(op),
          bottomLeft: true,
        ),
      ),
      Positioned(
        bottom: 0,
        right: 20,
        child: _CornerBracket(
          size: s,
          color: c.withOpacity(op),
          bottomRight: true,
        ),
      ),
    ];
  }
}

class _VoiceGuidedIllustration extends StatefulWidget {
  const _VoiceGuidedIllustration();

  @override
  State<_VoiceGuidedIllustration> createState() =>
      _VoiceGuidedIllustrationState();
}

class _VoiceGuidedIllustrationState extends State<_VoiceGuidedIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height * 0.55;

    return SizedBox(
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(color: const Color(0xFF0077FF)),
            ),
          ),

          // Camera frame
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF0077FF).withOpacity(0.35),
                width: 1.5,
              ),
              color: const Color(0xFF030810),
            ),
            child: Stack(
              children: [
                // Target object inside camera
                Positioned(
                  top: 24,
                  left: 20,
                  child: Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFF1A2535),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                  ),
                ),

                // Pulsing AR overlay box
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Positioned(
                    top: 20,
                    left: 16,
                    child: Container(
                      width: 88,
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(
                            0xFF00D2B4,
                          ).withOpacity(0.4 + _pulseAnim.value * 0.6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // "Detected" badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: _ARLabel(
                    label: 'Router detected',
                    color: const Color(0xFF00D2B4),
                  ),
                ),

                // AR arrow pointing right
                Positioned(
                  top: 52,
                  left: 108,
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 1.5,
                        color: const Color(0xFF00D2B4),
                      ),
                      const Icon(
                        Icons.arrow_right,
                        color: Color(0xFF00D2B4),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Step chip 1
          Positioned(
            bottom: h * 0.22,
            left: 24,
            child: _StepChip(
              step: '01',
              label: 'Remove cover',
              color: const Color(0xFF0077FF),
            ),
          ),

          // Step chip 2
          Positioned(
            bottom: h * 0.12,
            right: 24,
            child: _StepChip(
              step: '02',
              label: 'Locate antenna',
              color: const Color(0xFF00D2B4),
            ),
          ),

          // Voice mic indicator
          Positioned(
            bottom: h * 0.04,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00D2B4).withOpacity(0.15),
                    border: Border.all(
                      color: const Color(0xFF00D2B4).withOpacity(0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Color(0xFF00D2B4),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Voice guidance active',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityIllustration extends StatefulWidget {
  const _CommunityIllustration();

  @override
  State<_CommunityIllustration> createState() => _CommunityIllustrationState();
}

class _CommunityIllustrationState extends State<_CommunityIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height * 0.55;

    return SizedBox(
      height: h,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(color: const Color(0xFF00D2B4)),
              ),
            ),

            // Tutorial cards stack
            Positioned(
              top: h * 0.12,
              child: Column(
                children: [
                  _TutorialCard(
                    icon: Icons.router,
                    title: 'Router antenna fix',
                    author: 'by techfix_pro',
                    views: '12.4k',
                  ),
                  const SizedBox(height: 10),
                  _TutorialCard(
                    icon: Icons.computer,
                    title: 'PC GPU replacement',
                    author: 'by hardwarehero',
                    views: '8.1k',
                  ),
                  const SizedBox(height: 10),
                  _TutorialCard(
                    icon: Icons.pedal_bike,
                    title: 'Bike brake cable repair',
                    author: 'by bikewrench',
                    views: '5.6k',
                  ),
                ],
              ),
            ),

            // Safety warning chip
            Positioned(
              bottom: h * 0.06,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange.withOpacity(0.12),
                  border: Border.all(color: Colors.orange.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Safety warnings included',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.orange.withOpacity(0.8),
                      ),
                    ),
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

// ── AR floating label with dot + line
class _ARLabel extends StatelessWidget {
  final String label;
  final Color color;
  final bool alignRight;

  const _ARLabel({
    required this.label,
    required this.color,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Step chip (numbered)
class _StepChip extends StatelessWidget {
  final String step;
  final String label;
  final Color color;

  const _StepChip({
    required this.step,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            step,
            style: GoogleFonts.syne(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: color.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Community tutorial card
class _TutorialCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String author;
  final String views;

  const _TutorialCard({
    required this.icon,
    required this.title,
    required this.author,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF0D1525),
        border: Border.all(color: const Color(0xFF00D2B4).withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF00D2B4).withOpacity(0.1),
            ),
            child: Icon(icon, color: const Color(0xFF00D2B4), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  author,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
          ),
          Text(
            views,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: const Color(0xFF00D2B4).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Corner bracket widget
class _CornerBracket extends StatelessWidget {
  final double size;
  final Color color;
  final bool topLeft, topRight, bottomLeft, bottomRight;

  const _CornerBracket({
    required this.size,
    required this.color,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BracketPainter(
          color: color,
          strokeWidth: 1.5,
          showTop: topLeft || topRight,
          showBottom: bottomLeft || bottomRight,
          showLeft: topLeft || bottomLeft,
          showRight: topRight || bottomRight,
        ),
      ),
    );
  }
}

// ── Grid background painter
class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({this.color = const Color(0xFF00D2B4)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..strokeWidth = 0.5;

    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// ── Motherboard lines painter (slide 1 device)
class _MotherboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0077FF).withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Horizontal trace
    canvas.drawLine(
      Offset(12, size.height / 2),
      Offset(size.width - 12, size.height / 2),
      paint,
    );
    // Vertical trace
    canvas.drawLine(
      Offset(size.width / 2, 10),
      Offset(size.width / 2, size.height - 10),
      paint,
    );
    // CPU chip
    final chipPaint = Paint()
      ..color = const Color(0xFF00D2B4).withOpacity(0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: 36,
          height: 28,
        ),
        const Radius.circular(4),
      ),
      chipPaint,
    );

    // Small cap circles
    final dotPaint = Paint()
      ..color = const Color(0xFF0077FF).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    canvas.drawCircle(const Offset(22, 22), 6, dotPaint);
    canvas.drawCircle(Offset(size.width - 22, size.height - 22), 5, dotPaint);
  }

  @override
  bool shouldRepaint(_MotherboardPainter old) => false;
}

// ── AR box painter (corner brackets around device)
class _ARBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D2B4).withOpacity(0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const l = 16.0; // bracket arm length

    // Top-left
    canvas.drawLine(Offset(0, l), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(l, 0), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - l, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, l), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height - l), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(l, size.height), paint);
    // Bottom-right
    canvas.drawLine(
      Offset(size.width - l, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - l),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ARBoxPainter old) => false;
}
