import 'package:fix_ar/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── DATA MODELS
class RepairStep {
  final int number;
  final String title;
  final String description;
  final String duration;
  final StepDifficulty difficulty;
  final bool hasSafetyWarning;
  final String? warningText;
  final List<String> tools;

  const RepairStep({
    required this.number,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    this.hasSafetyWarning = false,
    this.warningText,
    this.tools = const [],
  });
}

enum StepDifficulty { easy, medium, hard }

// ── STATIC DATA
const List<RepairStep> routerRepairSteps = [
  RepairStep(
    number: 1,
    title: 'Power off the router',
    description:
    'Hold the power button for 3 seconds until all LEDs turn off. Unplug the power cable from the wall socket and wait 30 seconds before proceeding.',
    duration: '1 min',
    difficulty: StepDifficulty.easy,
    hasSafetyWarning: true,
    warningText: 'Never open the router while it is powered on.',
    tools: ['Hand'],
  ),
  RepairStep(
    number: 2,
    title: 'Remove bottom cover screws',
    description:
    'Flip the router upside down. Use a Phillips #0 screwdriver to remove the 4 screws located at each corner. Keep screws in a safe place.',
    duration: '3 min',
    difficulty: StepDifficulty.easy,
    tools: ['Phillips #0 screwdriver', 'Screw tray'],
  ),
  RepairStep(
    number: 3,
    title: 'Detach antenna connectors',
    description:
    'Carefully lift the bottom cover. Locate the two antenna connector cables. Use your fingernail to gently pop each connector straight up — do not pull sideways.',
    duration: '4 min',
    difficulty: StepDifficulty.medium,
    hasSafetyWarning: true,
    warningText: 'Pull connectors straight up only. Sideways force will break the socket.',
    tools: ['Spudger', 'Tweezers'],
  ),
  RepairStep(
    number: 4,
    title: 'Replace antenna module',
    description:
    'Slide the old antenna module out of its housing. Align the new module and press it in firmly until it clicks. Reconnect the two antenna cables.',
    duration: '5 min',
    difficulty: StepDifficulty.medium,
    tools: ['Replacement antenna', 'Tweezers'],
  ),
  RepairStep(
    number: 5,
    title: 'Reassemble and test',
    description:
    'Reattach the bottom cover and tighten all 4 screws. Plug the router back in and power it on. Check signal strength in your network settings.',
    duration: '3 min',
    difficulty: StepDifficulty.easy,
    tools: ['Phillips #0 screwdriver'],
  ),
];

// ── SCREEN
class RepairStepsScreen extends StatefulWidget {
  const RepairStepsScreen({super.key});

  @override
  State<RepairStepsScreen> createState() => _RepairStepsScreenState();
}

class _RepairStepsScreenState extends State<RepairStepsScreen>
    with TickerProviderStateMixin {

  int _currentStep = 0;
  bool _voiceEnabled = true;
  final List<bool> _completedSteps = List.filled(routerRepairSteps.length, false);

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnim = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnim = Tween<double>(begin: 0, end: _progressValue).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _progressController.forward();
  }

  double get _progressValue =>
      (_currentStep + 1) / routerRepairSteps.length;

  void _goToStep(int index) {
    if (index < 0 || index >= routerRepairSteps.length) return;
    setState(() => _currentStep = index);
    _slideController.reset();
    _slideController.forward();
    _progressController.animateTo(
      (_currentStep + 1) / routerRepairSteps.length,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _markComplete() {
    setState(() => _completedSteps[_currentStep] = true);
    if (_currentStep < routerRepairSteps.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _goToStep(_currentStep + 1);
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal.withOpacity(0.12),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.teal, size: 36),
            ),
            const SizedBox(height: 16),
            Text('Repair Complete!', style: GoogleFonts.syne(
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
            )),
            const SizedBox(height: 8),
            Text('Great job fixing your TP-Link Router.',
                style: GoogleFonts.dmSans(
                  fontSize: 13, color: Colors.white.withOpacity(0.4),
                ), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: AppGradients.brand,
                ),
                child: Center(child: Text('Done', style: GoogleFonts.syne(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
                ))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _diffColor(StepDifficulty d) => switch (d) {
    StepDifficulty.easy   => AppColors.teal,
    StepDifficulty.medium => Colors.orange,
    StepDifficulty.hard   => AppColors.danger,
  };

  String _diffLabel(StepDifficulty d) => switch (d) {
    StepDifficulty.easy   => 'Easy',
    StepDifficulty.medium => 'Medium',
    StepDifficulty.hard   => 'Hard',
  };

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = routerRepairSteps[_currentStep];
    final isLast = _currentStep == routerRepairSteps.length - 1;
    final isCompleted = _completedSteps[_currentStep];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepHeader(step),
                        const SizedBox(height: 16),
                        if (step.hasSafetyWarning && step.warningText != null)
                          _buildSafetyWarning(step.warningText!),
                        if (step.hasSafetyWarning) const SizedBox(height: 14),
                        _buildDescription(step),
                        const SizedBox(height: 16),
                        if (step.tools.isNotEmpty) _buildTools(step.tools),
                        if (step.tools.isNotEmpty) const SizedBox(height: 16),
                        _buildStepNav(),
                        const SizedBox(height: 16),
                        _buildCompleteButton(isLast, isCompleted),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildStepDots(),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          Column(children: [
            Text('TP-Link Router', style: GoogleFonts.syne(
              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
            )),
            Text('Antenna replacement', style: GoogleFonts.dmSans(
              fontSize: 10, color: Colors.white.withOpacity(0.35),
            )),
          ]),
          GestureDetector(
            onTap: () => setState(() => _voiceEnabled = !_voiceEnabled),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _voiceEnabled
                    ? AppColors.teal.withOpacity(0.12)
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: _voiceEnabled
                      ? AppColors.teal.withOpacity(0.35)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Icon(
                _voiceEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                color: _voiceEnabled
                    ? AppColors.teal
                    : Colors.white.withOpacity(0.3),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PROGRESS BAR
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step ${_currentStep + 1} of ${routerRepairSteps.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, color: Colors.white.withOpacity(0.35),
                  )),
              Text('${((_currentStep + 1) / routerRepairSteps.length * 100).round()}%',
                  style: GoogleFonts.syne(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppColors.teal,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: _progressAnim.value,
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.07),
                valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP HEADER
  Widget _buildStepHeader(RepairStep step) {
    return Row(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.teal, AppColors.blue],
            ),
          ),
          child: Center(
            child: Text('${step.number}', style: GoogleFonts.syne(
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
            )),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title, style: GoogleFonts.syne(
                fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white,
                height: 1.2,
              )),
              const SizedBox(height: 6),
              Row(children: [
                _MetaChip(
                  icon: Icons.timer_outlined,
                  label: step.duration,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(width: 8),
                _MetaChip(
                  icon: Icons.bar_chart_rounded,
                  label: _diffLabel(step.difficulty),
                  color: _diffColor(step.difficulty),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // ── SAFETY WARNING
  Widget _buildSafetyWarning(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.withOpacity(0.08),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.dmSans(
              fontSize: 12, color: Colors.orange.withOpacity(0.9),
              height: 1.5,
            )),
          ),
        ],
      ),
    );
  }

  // ── DESCRIPTION
  Widget _buildDescription(RepairStep step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Text(step.description, style: GoogleFonts.dmSans(
        fontSize: 14, color: Colors.white.withOpacity(0.75),
        height: 1.7,
      )),
    );
  }

  // ── TOOLS NEEDED
  Widget _buildTools(List<String> tools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tools needed', style: GoogleFonts.syne(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.6),
        )),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: tools.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.blue.withOpacity(0.08),
              border: Border.all(
                  color: AppColors.blue.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.build_rounded,
                    color: AppColors.blue, size: 12),
                const SizedBox(width: 6),
                Text(t, style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.blue,
                  fontWeight: FontWeight.w500,
                )),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  // ── PREV / NEXT NAVIGATION
  Widget _buildStepNav() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _currentStep > 0
                ? () => _goToStep(_currentStep - 1)
                : null,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.04),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_ios_rounded,
                      color: _currentStep > 0
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white.withOpacity(0.15),
                      size: 14),
                  const SizedBox(width: 6),
                  Text('Previous', style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: _currentStep > 0
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.15),
                  )),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: _currentStep < routerRepairSteps.length - 1
                ? () => _goToStep(_currentStep + 1)
                : null,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.04),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next', style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: _currentStep < routerRepairSteps.length - 1
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.15),
                  )),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: _currentStep < routerRepairSteps.length - 1
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white.withOpacity(0.15),
                      size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── COMPLETE BUTTON
  Widget _buildCompleteButton(bool isLast, bool isCompleted) {
    return GestureDetector(
      onTap: isCompleted ? null : _markComplete,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isCompleted
              ? null
              : AppGradients.brand,
          color: isCompleted ? Colors.white.withOpacity(0.05) : null,
          border: isCompleted
              ? Border.all(color: Colors.white.withOpacity(0.08))
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : (isLast
                    ? Icons.check_circle_outline_rounded
                    : Icons.arrow_forward_rounded),
                color: isCompleted
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isCompleted
                    ? 'Step completed'
                    : (isLast ? 'Complete Repair' : 'Mark & Continue'),
                style: GoogleFonts.syne(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: isCompleted
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── STEP DOTS
  Widget _buildStepDots() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(routerRepairSteps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = _completedSteps[i];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isDone
                  ? AppColors.teal
                  : isActive
                  ? AppColors.teal
                  : Colors.white.withOpacity(0.15),
            ),
          );
        }),
      ),
    );
  }
}

// ── META CHIP
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.dmSans(
          fontSize: 11, color: color, fontWeight: FontWeight.w500,
        )),
      ],
    );
  }
}