import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_ar/constants/constant.dart';
import 'package:fix_ar/widgets/app_widgets.dart';

class RepairStep {
  final int number;
  final String title, description, duration;
  final StepDifficulty difficulty;
  final bool hasSafetyWarning;
  final String? warningText;
  final List<String> tools;

  const RepairStep({
    required this.number, required this.title, required this.description,
    required this.duration, required this.difficulty,
    this.hasSafetyWarning = false, this.warningText, this.tools = const [],
  });
}

enum StepDifficulty { easy, medium, hard }

const List<RepairStep> routerRepairSteps = [
  RepairStep(number: 1, title: 'Power off the router',
      description: 'Hold the power button for 3 seconds until all LEDs turn off. Unplug the power cable from the wall socket and wait 30 seconds before proceeding.',
      duration: '1 min', difficulty: StepDifficulty.easy,
      hasSafetyWarning: true, warningText: 'Never open the router while it is powered on.',
      tools: ['Hand']),
  RepairStep(number: 2, title: 'Remove bottom cover screws',
      description: 'Flip the router upside down. Use a Phillips #0 screwdriver to remove the 4 screws located at each corner. Keep screws in a safe place.',
      duration: '3 min', difficulty: StepDifficulty.easy,
      tools: ['Phillips #0 screwdriver', 'Screw tray']),
  RepairStep(number: 3, title: 'Detach antenna connectors',
      description: 'Carefully lift the bottom cover. Locate the two antenna connector cables. Use your fingernail to gently pop each connector straight up — do not pull sideways.',
      duration: '4 min', difficulty: StepDifficulty.medium,
      hasSafetyWarning: true, warningText: 'Pull connectors straight up only. Sideways force will break the socket.',
      tools: ['Spudger', 'Tweezers']),
  RepairStep(number: 4, title: 'Replace antenna module',
      description: 'Slide the old antenna module out of its housing. Align the new module and press it in firmly until it clicks. Reconnect the two antenna cables.',
      duration: '5 min', difficulty: StepDifficulty.medium,
      tools: ['Replacement antenna', 'Tweezers']),
  RepairStep(number: 5, title: 'Reassemble and test',
      description: 'Reattach the bottom cover and tighten all 4 screws. Plug the router back in and power it on. Check signal strength in your network settings.',
      duration: '3 min', difficulty: StepDifficulty.easy,
      tools: ['Phillips #0 screwdriver']),
];

class RepairStepsScreen extends StatefulWidget {
  const RepairStepsScreen({super.key});
  @override
  State<RepairStepsScreen> createState() => _RepairStepsScreenState();
}

class _RepairStepsScreenState extends State<RepairStepsScreen> with TickerProviderStateMixin {
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
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _slideController, curve: Curves.easeOut);
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _progressAnim = Tween<double>(begin: 0, end: _progressValue)
        .animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    _slideController.forward();
    _progressController.forward();
  }

  double get _progressValue => (_currentStep + 1) / routerRepairSteps.length;

  void _goToStep(int index) {
    if (index < 0 || index >= routerRepairSteps.length) return;
    setState(() => _currentStep = index);
    _slideController.reset(); _slideController.forward();
    _progressController.animateTo((_currentStep + 1) / routerRepairSteps.length,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _markComplete() {
    setState(() => _completedSteps[_currentStep] = true);
    if (_currentStep < routerRepairSteps.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () => _goToStep(_currentStep + 1));
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
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 64, height: 64,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal.withOpacity(0.12)),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 36)),
          const SizedBox(height: 16),
          Text('Repair Complete!', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Great job fixing your TP-Link Router.',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.white40), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          AppGradientButton(label: 'Done', onTap: () { Navigator.pop(context); Navigator.pop(context); }, height: 46),
        ]),
      ),
    );
  }

  Color _diffColor(StepDifficulty d) => switch (d) {
    StepDifficulty.easy   => AppColors.teal,
    StepDifficulty.medium => AppColors.warning,
    StepDifficulty.hard   => AppColors.danger,
  };

  String _diffLabel(StepDifficulty d) => switch (d) {
    StepDifficulty.easy   => 'Easy',
    StepDifficulty.medium => 'Medium',
    StepDifficulty.hard   => 'Hard',
  };

  @override
  void dispose() { _slideController.dispose(); _progressController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final step = routerRepairSteps[_currentStep];
    final isLast = _currentStep == routerRepairSteps.length - 1;
    final isCompleted = _completedSteps[_currentStep];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
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
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildStepHeader(step),
                    const SizedBox(height: 16),
                    if (step.hasSafetyWarning && step.warningText != null) ...[
                      AppSafetyWarning(text: step.warningText!, padding: const EdgeInsets.all(12)),
                      const SizedBox(height: 14),
                    ],
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16), color: AppColors.white4,
                        border: Border.all(color: AppColors.white7),
                      ),
                      child: Text(step.description, style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.white75, height: 1.7)),
                    ),
                    if (step.tools.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildTools(step.tools),
                    ],
                    const SizedBox(height: 16),
                    _buildStepNav(),
                    const SizedBox(height: 16),
                    _buildCompleteButton(isLast, isCompleted),
                  ]),
                ),
              ),
            ),
          ),
          _buildStepDots(),
        ]),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        AppBackButton(),
        Column(children: [
          Text('TP-Link Router', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('Antenna replacement', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.white35)),
        ]),
        GestureDetector(
          onTap: () => setState(() => _voiceEnabled = !_voiceEnabled),
          child: AppIconButton(
            icon: _voiceEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
            iconColor: _voiceEnabled ? AppColors.teal : AppColors.white30,
            backgroundColor: _voiceEnabled ? AppColors.teal.withOpacity(0.12) : AppColors.white5,
            borderColor: _voiceEnabled ? AppColors.teal.withOpacity(0.35) : AppColors.white8,
            iconSize: 16,
          ),
        ),
      ]),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Step ${_currentStep + 1} of ${routerRepairSteps.length}',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.white35)),
          Text('${((_currentStep + 1) / routerRepairSteps.length * 100).round()}%',
              style: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)),
        ]),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnim,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: _progressAnim.value, minHeight: 4,
                backgroundColor: AppColors.white7,
                valueColor: const AlwaysStoppedAnimation(AppColors.teal)),
          ),
        ),
      ]),
    );
  }

  Widget _buildStepHeader(RepairStep step) {
    return Row(children: [
      Container(width: 48, height: 48,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: AppGradients.brandDiagonal),
          child: Center(child: Text('${step.number}',
              style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(step.title, style: GoogleFonts.syne(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
        const SizedBox(height: 6),
        Row(children: [
          _MetaChip(icon: Icons.timer_outlined, label: step.duration, color: AppColors.white30),
          const SizedBox(width: 8),
          _MetaChip(icon: Icons.bar_chart_rounded, label: _diffLabel(step.difficulty), color: _diffColor(step.difficulty)),
        ]),
      ])),
    ]);
  }

  Widget _buildTools(List<String> tools) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tools needed', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white60)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: tools.map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.blue.withOpacity(0.08),
            border: Border.all(color: AppColors.blue.withOpacity(0.2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.build_rounded, color: AppColors.blue, size: 12),
            const SizedBox(width: 6),
            Text(t, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.blue, fontWeight: FontWeight.w500)),
          ]),
        )).toList(),
      ),
    ]);
  }

  Widget _buildStepNav() {
    final canPrev = _currentStep > 0;
    final canNext = _currentStep < routerRepairSteps.length - 1;
    return Row(children: [
      Expanded(
        child: AppOutlineButton(
          label: 'Previous', onTap: canPrev ? () => _goToStep(_currentStep - 1) : null,
          labelColor: canPrev ? AppColors.white60 : AppColors.white25,
          leading: Icon(Icons.arrow_back_ios_rounded, color: canPrev ? AppColors.white60 : AppColors.white25, size: 14),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: AppOutlineButton(
          label: 'Next', onTap: canNext ? () => _goToStep(_currentStep + 1) : null,
          labelColor: canNext ? AppColors.white60 : AppColors.white25,
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: canNext ? AppColors.white60 : AppColors.white25, size: 14),
        ),
      ),
    ]);
  }

  Widget _buildCompleteButton(bool isLast, bool isCompleted) {
    return GestureDetector(
      onTap: isCompleted ? null : _markComplete,
      child: Container(
        width: double.infinity, height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isCompleted ? null : AppGradients.brand,
          color: isCompleted ? AppColors.white5 : null,
          border: isCompleted ? Border.all(color: AppColors.white8) : null,
        ),
        child: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              isCompleted ? Icons.check_circle_rounded : (isLast ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded),
              color: isCompleted ? AppColors.white30 : Colors.white, size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isCompleted ? 'Step completed' : (isLast ? 'Complete Repair' : 'Mark & Continue'),
              style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700,
                  color: isCompleted ? AppColors.white30 : Colors.white),
            ),
          ]),
        ),
      ),
    );
  }

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
            width: isActive ? 24 : 8, height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: (isDone || isActive) ? AppColors.teal : AppColors.white20,
            ),
          );
        }),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}
