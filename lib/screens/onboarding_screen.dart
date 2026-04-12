import 'package:fix_ar/constants/constant.dart';
import 'package:fix_ar/widgets/onboarding_illustration_panel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingData {
  final String title;
  final String titleHighlight;
  final String description;
  final OnboardingIllustration illustration;

  OnboardingData({
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.illustration,
  });
}

enum OnboardingIllustration { pointAndDetect, voiceGuided, community }

List<OnboardingData> onboardingSlides = [
  OnboardingData(
    title: 'Point. Detect.\n',
    titleHighlight: 'Repair instantly.',
    description:
    'Aim your camera at any device — router, PC, bike — and FixAR identifies every component with live AR overlays.',
    illustration: OnboardingIllustration.pointAndDetect,
  ),
  OnboardingData(
    title: 'AR steps,\n',
    titleHighlight: 'voice guided.',
    description:
    'Follow animated AR arrows and real-time overlays. Hear each step read aloud — hands stay on the repair, not the screen.',
    illustration: OnboardingIllustration.voiceGuided,
  ),
  OnboardingData(
    title: 'Community\n',
    titleHighlight: 'repairs & parts.',
    description:
    'Browse thousands of community repair tutorials. Get instant parts recommendations with safety warnings built in.',
    illustration: OnboardingIllustration.community,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    _initContentAnimation();
    super.initState();
  }

  void _initContentAnimation() {
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(parent: _contentController, curve: Curves.easeOut);
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
        );
    _contentController.forward();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentController.reset();
    _contentController.forward();
  }

  void _nextPage() {
    if (_currentPage < onboardingSlides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, "/auth");
    }
  }

  void _skip() => Navigator.pushReplacementNamed(context, "/auth");

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return OnboardingIllustrationPanel(
                illustration: onboardingSlides[index].illustration,
              );
            },
          ),
          Align(alignment: Alignment.bottomCenter, child: _buildBottomSheet()),
          Positioned(
            top: 80, right: 20,
            child: GestureDetector(
              onTap: _skip,
              child: Text(
                "Skip",
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  color: AppColors.white30,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    final slide = onboardingSlides[_currentPage];
    final isLast = _currentPage == onboardingSlides.length - 1;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        border: Border.all(color: AppColors.teal, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
      child: FadeTransition(
        opacity: _contentFade,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDotIndicators(),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: slide.title,
                    style: GoogleFonts.syne(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: -0.5, height: 1.15,
                    ),
                  ),
                  TextSpan(
                    text: slide.titleHighlight,
                    style: GoogleFonts.syne(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: AppColors.teal, letterSpacing: -0.5, height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              slide.description,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.white45,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 32),
            _buildCTAButton(isLast),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      children: List.generate(onboardingSlides.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isActive ? AppGradients.brand : null,
            color: isActive ? null : AppColors.white12,
          ),
        );
      }),
    );
  }

  Widget _buildCTAButton(bool isLast) {
    return GestureDetector(
      onTap: _nextPage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: AppGradients.brand,
        ),
        child: Center(
          child: Text(
            isLast ? "Get Started" : "Next",
            style: GoogleFonts.syne(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}