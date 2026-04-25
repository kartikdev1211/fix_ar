import 'package:camera/camera.dart';
import 'package:fix_ar/models/detected_device_model.dart';

class CameraState {
  final CameraController? controller;
  final bool ready, flashOn, detected;
  final int selectedCamera, selectedMode;
  final DetectedDeviceModel? device;

  const CameraState({
    this.controller, this.ready = false, this.flashOn = false,
    this.detected = false, this.selectedCamera = 0, this.selectedMode = 0, this.device,
  });

  CameraState copyWith({CameraController? controller, bool? ready, bool? flashOn, bool? detected, int? selectedCamera, int? selectedMode, DetectedDeviceModel? device, bool clearDevice = false}) =>
      CameraState(
        controller: controller ?? this.controller,
        ready: ready ?? this.ready,
        flashOn: flashOn ?? this.flashOn,
        detected: detected ?? this.detected,
        selectedCamera: selectedCamera ?? this.selectedCamera,
        selectedMode: selectedMode ?? this.selectedMode,
        device: clearDevice ? null : device ?? this.device,
      );
}