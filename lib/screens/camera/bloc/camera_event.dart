import 'package:fix_ar/models/detected_device_model.dart';

abstract class CameraEvent {}

class CameraInit extends CameraEvent {}

class CameraFlipRequested extends CameraEvent {}

class CameraFlashToggled extends CameraEvent {}

class CameraScanReset extends CameraEvent {}

class CameraDetected extends CameraEvent {
  final DetectedDeviceModel device;

  CameraDetected(this.device);
}

class CameraModeChanged extends CameraEvent {
  final int index;

  CameraModeChanged(this.index);
}
