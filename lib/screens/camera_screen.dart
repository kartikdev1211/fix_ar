import 'dart:async';

import 'package:camera/camera.dart';
import 'package:fix_ar/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

enum DetectionState { scanning, detected }

class DetectedDevice {
  final String name;
  final String model;
  final int guideCount;
  final int confidence;
  final Color accent;
  final IconData icon;

  DetectedDevice({
    required this.name,
    required this.model,
    required this.guideCount,
    required this.confidence,
    required this.accent,
    required this.icon,
  });
}

class ARLabel {
  final String text;
  final Color color;
  final Offset position;

  ARLabel({required this.text, required this.color, required this.position});
}

class ARCameraScreen extends StatefulWidget {
  const ARCameraScreen({super.key});

  @override
  State<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends State<ARCameraScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;
  bool _flashOn = false;
  int _selectedCameraIndex = 0;
  DetectionState _state = DetectionState.scanning;
  int _selectedMode = 0;
  final List<String> _modes = ['Detect', 'Repair', 'Parts', 'Manual'];
  DetectedDevice? _detectedDevice;
  final List<ARLabel> _arLabels = [
    ARLabel(
      text: 'Power',
      color: AppColors.teal,
      position: Offset(0.72, 0.42),
    ),
    ARLabel(
      text: 'Reset',
      color: AppColors.blue,
      position: Offset(0.70, 0.48),
    ),
    ARLabel(
      text: 'Antenna',
      color: AppColors.orange,
      position: Offset(0.10, 0.37),
    ),
  ];
  late AnimationController _scanController;
  late Animation<double> _scanAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  late AnimationController _labelController;
  late Animation<double> _labelFade;

  late AnimationController _cardController;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initAnimations();
    _initCamera();
  }

  // ── ANIMATIONS SETUP
  void _initAnimations() {
    // Scanline sweeps top → bottom
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(_scanController);

    // Reticle pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // AR labels fade in
    _labelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _labelFade = CurvedAnimation(
      parent: _labelController,
      curve: Curves.easeOut,
    );

    // Result card slides up
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _cameraReady = false);
      return;
    }

    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    await _startCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _startCamera(CameraDescription cam) async {
    final controller = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _cameraReady = true;
      });
      _simulateDetection();
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void _simulateDetection() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _state = DetectionState.detected;
        _detectedDevice = DetectedDevice(
          name: "TP-Link Router",
          model: "Archer C6",
          guideCount: 4,
          confidence: 82,
          accent: AppColors.teal,
          icon: Icons.router_rounded,
        );
      });
      _labelController.forward();
      _cardController.forward();
    });
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _cameraController?.dispose();
    setState(() => _cameraReady = false);
    await _startCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    setState(() => _flashOn = !_flashOn);
    await _cameraController!.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  void _resetScan() {
    setState(() {
      _state = DetectionState.scanning;
      _detectedDevice = null;
    });
    _labelController.reset();
    _cardController.reset();
    _simulateDetection();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cameraController?.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    _labelController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── 1. CAMERA PREVIEW (full screen)
          _buildCameraPreview(size),

          // ── 2. GRID OVERLAY
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // ── 3. SCANLINE (only while scanning)
          if (_state == DetectionState.scanning)
            AnimatedBuilder(
              animation: _scanAnim,
              builder: (_, __) => Positioned(
                top: size.height * _scanAnim.value,
                left: 0, right: 0,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      AppColors.teal.withOpacity(0.6),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),

          // ── 4. AR RETICLE (center)
          Center(child: _buildReticle()),

          // ── 5. AR LABELS (fade in on detection)
          if (_state == DetectionState.detected)
            ..._buildARLabels(size),

          // ── 6. DETECTION BADGE + CONFIDENCE BAR
          if (_state == DetectionState.detected)
            _buildDetectionBadge(size),

          // ── 7. TOP BAR
          _buildTopBar(),

          // ── 8. BOTTOM CONTROLS
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomControls(),
          ),

          // ── 9. RESULT CARD (slides up on detection)
          if (_state == DetectionState.detected && _detectedDevice != null)
            Positioned(
              bottom: 110, left: 16, right: 16,
              child: SlideTransition(
                position: _cardSlide,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: _buildResultCard(_detectedDevice!),
                ),
              ),
            ),

          // ── 10. PERMISSION DENIED MESSAGE
          if (!_cameraReady)
            _buildPermissionDenied(),

        ],
      ),
    );
  }

  // ── CAMERA PREVIEW
  Widget _buildCameraPreview(Size size) {
    if (!_cameraReady || _cameraController == null) {
      return Container(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.teal,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text('Initializing camera...',
                  style: GoogleFonts.dmSans(
                    color: Colors.white38, fontSize: 13,
                  )),
            ],
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  // ── AR RETICLE
  Widget _buildReticle() {
    final isDetected = _state == DetectionState.detected;
    final color = isDetected
        ? AppColors.teal
        : AppColors.teal;

    return SizedBox(
      width: 200, height: 150,
      child: Stack(
        children: [

          // Pulse ring
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: color.withOpacity(
                      isDetected ? 0 : 0.15 + _pulseAnim.value * 0.25,
                    ),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

          // Corner brackets
          CustomPaint(
            size: const Size(200, 150),
            painter: _ReticlePainter(
              color: color,
              isDetected: isDetected,
            ),
          ),
        ],
      ),
    );
  }

  // ── AR LABELS
  List<Widget> _buildARLabels(Size size) {
    return _arLabels.map((label) {
      return Positioned(
        left: size.width * label.position.dx,
        top: size.height * label.position.dy,
        child: FadeTransition(
          opacity: _labelFade,
          child: _ARLabelWidget(label: label),
        ),
      );
    }).toList();
  }

  // ── DETECTION BADGE + CONFIDENCE
  Widget _buildDetectionBadge(Size size) {
    return Positioned(
      top: size.height * 0.58,
      left: 0, right: 0,
      child: FadeTransition(
        opacity: _cardFade,
        child: Column(
          children: [

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.teal.withOpacity(0.15),
                border: Border.all(
                  color: AppColors.teal.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Router detected — ${_detectedDevice?.confidence ?? 0}% confidence',
                    style: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w500,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Confidence bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Detection confidence',
                          style: GoogleFonts.dmSans(
                            fontSize: 9, color: Colors.white38,
                          )),
                      Text('${_detectedDevice?.confidence ?? 0}%',
                          style: GoogleFonts.dmSans(
                            fontSize: 9, color: Colors.white38,
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (_detectedDevice?.confidence ?? 0) / 100,
                      minHeight: 3,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: const AlwaysStoppedAnimation(AppColors.teal),
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

  // ── TOP BAR
  Widget _buildTopBar() {
    final isDetected = _state == DetectionState.detected;

    return Positioned(
      top: 0, left: 0, right: 0,
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

            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: _TopBarButton(
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 16),
              ),
            ),

            // Mode label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.4),
                border: Border.all(
                  color: isDetected
                      ? AppColors.teal.withOpacity(0.4)
                      : Colors.white.withOpacity(0.12),
                ),
              ),
              child: Text(
                isDetected ? 'Detected' : 'Scan Mode',
                style: GoogleFonts.syne(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: isDetected
                      ? AppColors.teal
                      : Colors.white,
                ),
              ),
            ),

            // Info button
            _TopBarButton(
              child: const Icon(Icons.info_outline_rounded,
                  color: Colors.white, size: 16),
            ),

          ],
        ),
      ),
    );
  }

  // ── BOTTOM CONTROLS
  Widget _buildBottomControls() {
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

          // Mode chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _modes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final isActive = i == _selectedMode;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMode = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isActive
                          ? AppColors.teal.withOpacity(0.15)
                          : Colors.black.withOpacity(0.3),
                      border: Border.all(
                        color: isActive
                            ? AppColors.teal.withOpacity(0.5)
                            : Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: Text(_modes[i], style: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w500,
                      color: isActive
                          ? AppColors.teal
                          : Colors.white.withOpacity(0.4),
                    )),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Flash + Shutter + Flip row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Flash
              GestureDetector(
                onTap: _toggleFlash,
                child: _ControlButton(
                  child: Icon(
                    _flashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    color: _flashOn
                        ? AppColors.teal
                        : Colors.white,
                    size: 20,
                  ),
                ),
              ),

              // Shutter
              GestureDetector(
                onTap: _state == DetectionState.detected
                    ? _resetScan
                    : null,
                child: Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.teal.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 54, height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.teal, AppColors.blue],
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

              // Flip camera
              GestureDetector(
                onTap: _flipCamera,
                child: _ControlButton(
                  child: const Icon(Icons.flip_camera_ios_rounded,
                      color: Colors.white, size: 20),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

  // ── RESULT CARD
  Widget _buildResultCard(DetectedDevice device) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.background.withOpacity(0.95),
        border: Border.all(
          color: AppColors.teal.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Device row
          Row(
            children: [
              Container(
                width: 42, height: 42,
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
                    Text(device.name, style: GoogleFonts.syne(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                    Text(
                      'Model: ${device.model} · ${device.guideCount} repair guides',
                      style: GoogleFonts.dmSans(
                        fontSize: 10, color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: device.accent.withOpacity(0.12),
                  border: Border.all(
                      color: device.accent.withOpacity(0.3)),
                ),
                child: Text('${device.confidence}%',
                    style: GoogleFonts.syne(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: device.accent,
                    )),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/repair-steps'),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [AppColors.teal, AppColors.blue],
                      ),
                    ),
                    child: Center(
                      child: Text('Start Repair', style: GoogleFonts.syne(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/parts'),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Text('View Parts', style: GoogleFonts.syne(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.5),
                      )),
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

  // ── PERMISSION DENIED
  Widget _buildPermissionDenied() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined,
                color: Colors.white.withOpacity(0.2), size: 48),
            const SizedBox(height: 16),
            Text('Camera access required',
                style: GoogleFonts.syne(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
            const SizedBox(height: 8),
            Text('Enable camera in device settings',
                style: GoogleFonts.dmSans(
                  fontSize: 12, color: Colors.white38,
                )),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _initCamera,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: AppGradients.brand,
                ),
                child: Text('Try Again', style: GoogleFonts.syne(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ── TOP BAR BUTTON
class _TopBarButton extends StatelessWidget {
  final Widget child;
  const _TopBarButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.5),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Center(child: child),
    );
  }
}

// ── CONTROL BUTTON
class _ControlButton extends StatelessWidget {
  final Widget child;
  const _ControlButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46, height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Center(child: child),
    );
  }
}

// ── AR LABEL WIDGET
class _ARLabelWidget extends StatelessWidget {
  final ARLabel label;
  const _ARLabelWidget({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7, height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: label.color,
            boxShadow: [BoxShadow(color: label.color.withOpacity(0.6), blurRadius: 4)],
          ),
        ),
        Container(
          width: 20, height: 1.5,
          color: label.color.withOpacity(0.6),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: label.color.withOpacity(0.15),
            border: Border.all(color: label.color.withOpacity(0.5)),
          ),
          child: Text(label.text, style: GoogleFonts.dmSans(
            fontSize: 10, fontWeight: FontWeight.w500,
            color: label.color,
          )),
        ),
      ],
    );
  }
}

// ── RETICLE PAINTER
class _ReticlePainter extends CustomPainter {
  final Color color;
  final bool isDetected;
  const _ReticlePainter({required this.color, required this.isDetected});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = isDetected ? 2.5 : 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const arm = 24.0;

    // Top-left
    canvas.drawLine(Offset(0, arm), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(arm, 0), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - arm, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height - arm), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - arm, size.height),
        Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - arm),
        Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ReticlePainter old) =>
      old.isDetected != isDetected;
}

// ── GRID PAINTER
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.teal.withOpacity(0.04)
      ..strokeWidth = 0.5;

    const spacing = 26.0;
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