import 'package:fix_ar/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:fix_ar/screens/onboarding/bloc/onboarding_event.dart';
import 'package:fix_ar/screens/onboarding/bloc/onboarding_state.dart';
import 'package:fix_ar/widgets/onboarding_illustration_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _initContentAnimation();
  }

  void _initContentAnimation() {
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _contentFade =
        CurvedAnimation(parent: _contentController, curve: Curves.easeOut);

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
        );

    _contentController.forward();
  }

  void _onPageChanged(int index) {
    context.read<OnboardingBloc>().add(PageChanged(index));

    _contentController.reset();
    _contentController.forward();
  }

  void _nextPage(OnboardingState state) {
    if (!state.isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    context.read<OnboardingBloc>().add(NextPressed());
  }

  void _skip() {
    context.read<OnboardingBloc>().add(SkipPressed());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state.navigateToAuth) {
            Navigator.pushReplacementNamed(context, "/auth");
          }
        },
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            final slide = onboardingSlides[state.currentPage];
            final isLast = state.isLastPage;

            return Scaffold(
              backgroundColor: const Color(0xFF080810),
              body: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: onboardingSlides.length,
                    itemBuilder: (context, index) {
                      return OnboardingIllustrationPanel(
                        illustration: onboardingSlides[index].illustration,
                      );
                    },
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildBottomSheet(state),
                  ),

                  Positioned(
                    top: 80,
                    right: 20,
                    child: GestureDetector(
                      onTap: _skip,
                      child: Text(
                        "Skip",
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          color: Colors.white30,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomSheet(OnboardingState state) {
    final slide = onboardingSlides[state.currentPage];
    final isLast = state.isLastPage;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: const Color(0xFF00D2B4), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
      child: FadeTransition(
        opacity: _contentFade,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDotIndicators(state),
            const SizedBox(height: 24),

            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: slide.title,
                    style: GoogleFonts.syne(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                  TextSpan(
                    text: slide.titleHighlight,
                    style: GoogleFonts.syne(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF00D2B4),
                      letterSpacing: -0.5,
                      height: 1.15,
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
                color: Colors.white.withOpacity(0.45),
                height: 1.65,
              ),
            ),

            const SizedBox(height: 32),

            _buildCTAButton(state, isLast),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicators(OnboardingState state) {
    return Row(
      children: List.generate(onboardingSlides.length, (index) {
        final isActive = index == state.currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isActive
                ? const LinearGradient(
              colors: [Color(0xFF00D2B4), Color(0xFF0077FF)],
            )
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildCTAButton(OnboardingState state, bool isLast) {
    return GestureDetector(
      onTap: () => _nextPage(state),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF00D2B4), Color(0xFF0077FF)],
          ),
        ),
        child: Center(
          child: Text(
            isLast ? "Get Started" : "Next",
            style: GoogleFonts.syne(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}