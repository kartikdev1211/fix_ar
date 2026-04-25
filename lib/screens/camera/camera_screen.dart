import 'dart:async';
import 'package:fix_ar/constants/constant.dart';
import 'package:camera/camera.dart';
import 'package:fix_ar/models/detected_device_model.dart';
import 'package:fix_ar/screens/camera/bloc/camera_bloc.dart';
import 'package:fix_ar/screens/camera/bloc/camera_event.dart';
import 'package:fix_ar/screens/camera/bloc/camera_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

const _arLabels = [
  ARLabel(
    text: 'Power',
    color: Color(0xFF00D2B4),
    position: Offset(0.72, 0.42),
  ),
  ARLabel(
    text: 'Reset',
    color: Color(0xFF0077FF),
    position: Offset(0.70, 0.48),
  ),
  ARLabel(
    text: 'Antenna',
    color: Color(0xFFFF6B35),
    position: Offset(0.10, 0.37),
  ),
];
const _modes = ['Detect', 'Repair', 'Parts', 'Manual'];

class ARCameraScreen extends StatefulWidget {
  const ARCameraScreen({super.key});
  @override
  State<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends State<ARCameraScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scanCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);
  late final AnimationController _cardCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _scanAnim = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(_scanCtrl);
  late final Animation<double> _pulseAnim = CurvedAnimation(
    parent: _pulseCtrl,
    curve: Curves.easeInOut,
  );
  late final Animation<Offset> _cardSlide = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
  late final Animation<double> _cardFade = CurvedAnimation(
    parent: _cardCtrl,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _requestAndInit();
  }

  Future<void> _requestAndInit() async {
    final status = await Permission.camera.request();
    if (status.isGranted) context.read<CameraBloc>().add(CameraInit());
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _onDetected() {
    _cardCtrl.forward();
  }

  void _onReset() {
    _cardCtrl.reset();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<CameraBloc, CameraState>(
      listener: (_, state) => state.detected ? _onDetected() : _onReset(),
      builder: (_, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              _Preview(state: state),
              Positioned.fill(child: CustomPaint(painter: _GridPainter())),
              if (!state.detected)
                AnimatedBuilder(
                  animation: _scanAnim,
                  builder: (_, __) => Positioned(
                    top: size.height * _scanAnim.value,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.teal.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Center(
                child: _Reticle(detected: state.detected, pulse: _pulseAnim),
              ),
              if (state.detected) ...[
                ..._arLabels.map(
                  (l) => Positioned(
                    left: size.width * l.position.dx,
                    top: size.height * l.position.dy,
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: _LabelWidget(label: l),
                    ),
                  ),
                ),
                _ConfidenceBadge(state: state, size: size, fade: _cardFade),
              ],
              _TopBar(state: state),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomControls(state: state),
              ),
              if (state.detected && state.device != null)
                Positioned(
                  bottom: 110,
                  left: 16,
                  right: 16,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: _ResultCard(device: state.device!),
                    ),
                  ),
                ),
              if (!state.ready) _PermissionDenied(onRetry: _requestAndInit),
            ],
          ),
        );
      },
    );
  }
}

// ── SUBWIDGETS ────────────────────────────────────────────────────────────────

class _Preview extends StatelessWidget {
  final CameraState state;
  const _Preview({required this.state});
  @override
  Widget build(BuildContext context) {
    if (!state.ready || state.controller == null)
      return Container(
        color: AppColors.background,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.teal,
            strokeWidth: 2,
          ),
        ),
      );
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: state.controller!.value.previewSize!.height,
          height: state.controller!.value.previewSize!.width,
          child: CameraPreview(state.controller!),
        ),
      ),
    );
  }
}

class _Reticle extends StatelessWidget {
  final bool detected;
  final Animation<double> pulse;
  const _Reticle({required this.detected, required this.pulse});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    height: 150,
    child: Stack(
      children: [
        AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.teal.withOpacity(
                    detected ? 0 : 0.15 + pulse.value * 0.25,
                  ),
                ),
              ),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(200, 150),
          painter: _ReticlePainter(detected: detected),
        ),
      ],
    ),
  );
}

class _LabelWidget extends StatelessWidget {
  final ARLabel label;
  const _LabelWidget({required this.label});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: label.color,
          boxShadow: [
            BoxShadow(color: label.color.withOpacity(0.6), blurRadius: 4),
          ],
        ),
      ),
      Container(width: 20, height: 1.5, color: label.color.withOpacity(0.6)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: label.color.withOpacity(0.15),
          border: Border.all(color: label.color.withOpacity(0.5)),
        ),
        child: Text(
          label.text,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: label.color,
          ),
        ),
      ),
    ],
  );
}

class _ConfidenceBadge extends StatelessWidget {
  final CameraState state;
  final Size size;
  final Animation<double> fade;
  const _ConfidenceBadge({
    required this.state,
    required this.size,
    required this.fade,
  });
  @override
  Widget build(BuildContext context) => Positioned(
    top: size.height * 0.58,
    left: 0,
    right: 0,
    child: FadeTransition(
      opacity: fade,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.teal.withOpacity(0.15),
              border: Border.all(color: AppColors.teal.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00D2B4),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Router detected — ${state.device?.confidence ?? 0}% confidence',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detection confidence',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: Colors.white38,
                      ),
                    ),
                    Text(
                      '${state.device?.confidence ?? 0}%',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (state.device?.confidence ?? 0) / 100,
                    minHeight: 3,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF00D2B4)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  final CameraState state;
  const _TopBar({required this.state});
  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _IconBtn(
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.4),
              border: Border.all(
                color: state.detected
                    ? AppColors.teal.withOpacity(0.4)
                    : Colors.white.withOpacity(0.12),
              ),
            ),
            child: Text(
              state.detected ? 'Detected' : 'Scan Mode',
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: state.detected ? AppColors.teal : Colors.white,
              ),
            ),
          ),
          _IconBtn(
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

class _BottomControls extends StatelessWidget {
  final CameraState state;
  const _BottomControls({required this.state});
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CameraBloc>();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.85), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _modes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final active = i == state.selectedMode;
                return GestureDetector(
                  onTap: () => bloc.add(CameraModeChanged(i)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: active
                          ? AppColors.teal.withOpacity(0.15)
                          : Colors.black.withOpacity(0.3),
                      border: Border.all(
                        color: active
                            ? AppColors.teal.withOpacity(0.5)
                            : Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: Text(
                      _modes[i],
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: active
                            ? AppColors.teal
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => bloc.add(CameraFlashToggled()),
                child: _IconBtn(
                  size: 46,
                  child: Icon(
                    state.flashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    color: state.flashOn ? AppColors.teal : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: state.detected
                    ? () => bloc.add(CameraScanReset())
                    : null,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.teal.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF00D2B4), Color(0xFF0077FF)],
                        ),
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => bloc.add(CameraFlipRequested()),
                child: _IconBtn(
                  size: 46,
                  child: const Icon(
                    Icons.flip_camera_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final DetectedDeviceModel device;
  const _ResultCard({required this.device});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: AppColors.background.withOpacity(0.95),
      border: Border.all(color: AppColors.teal.withOpacity(0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: device.accent.withOpacity(0.12),
              ),
              child: Icon(device.icon, color: device.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Model: ${device.model} · ${device.guideCount} repair guides',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: device.accent.withOpacity(0.12),
                border: Border.all(color: device.accent.withOpacity(0.3)),
              ),
              child: Text(
                '${device.confidence}%',
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: device.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/repair-steps'),
                child: Container(
                  height: 42,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    gradient: LinearGradient(
                      colors: [Color(0xFF00D2B4), Color(0xFF0077FF)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Start Repair',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/parts'),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Center(
                    child: Text(
                      'View Parts',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PermissionDenied extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionDenied({required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.background,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: Colors.white.withOpacity(0.2),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Camera access required',
            style: GoogleFonts.syne(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enable camera in device settings',
            style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white38),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                gradient: LinearGradient(
                  colors: [Color(0xFF00D2B4), Color(0xFF0077FF)],
                ),
              ),
              child: Text(
                'Try Again',
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
    ),
  );
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final double size;
  const _IconBtn({required this.child, this.size = 36});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size == 36 ? 10 : 14),
      color: Colors.white.withOpacity(0.08),
      border: Border.all(color: Colors.white.withOpacity(0.12)),
    ),
    child: Center(child: child),
  );
}

// ── PAINTERS ──────────────────────────────────────────────────────────────────

class _ReticlePainter extends CustomPainter {
  final bool detected;
  const _ReticlePainter({required this.detected});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.teal
      ..strokeWidth = detected ? 2.5 : 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const a = 24.0;
    canvas.drawLine(Offset(0, a), Offset.zero, p);
    canvas.drawLine(Offset.zero, Offset(a, 0), p);
    canvas.drawLine(Offset(size.width - a, 0), Offset(size.width, 0), p);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, a), p);
    canvas.drawLine(Offset(0, size.height - a), Offset(0, size.height), p);
    canvas.drawLine(Offset(0, size.height), Offset(a, size.height), p);
    canvas.drawLine(
      Offset(size.width - a, size.height),
      Offset(size.width, size.height),
      p,
    );
    canvas.drawLine(
      Offset(size.width, size.height - a),
      Offset(size.width, size.height),
      p,
    );
  }

  @override
  bool shouldRepaint(_ReticlePainter o) => o.detected != detected;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.teal.withOpacity(0.04)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 26)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 26)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(_GridPainter o) => false;
}
