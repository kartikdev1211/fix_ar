
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:fix_ar/models/detected_device_model.dart';
import 'package:fix_ar/screens/camera/bloc/camera_event.dart';
import 'package:fix_ar/screens/camera/bloc/camera_state.dart';
import 'package:flutter/material.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  List<CameraDescription> _cameras = [];

  CameraBloc() : super(const CameraState()) {
    on<CameraInit>(_onInit);
    on<CameraFlipRequested>(_onFlip);
    on<CameraFlashToggled>(_onFlash);
    on<CameraScanReset>(_onReset);
    on<CameraDetected>(_onDetected);
    on<CameraModeChanged>((e, emit) => emit(state.copyWith(selectedMode: e.index)));
  }

  Future<void> _onInit(CameraInit e, Emitter<CameraState> emit) async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    await _startCamera(0, emit);
    _scheduleDetection();
  }

  Future<void> _startCamera(int index, Emitter<CameraState> emit) async {
    final ctrl = CameraController(_cameras[index], ResolutionPreset.high, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    try {
      await ctrl.initialize();
      emit(state.copyWith(controller: ctrl, ready: true, selectedCamera: index));
    } catch (_) {}
  }

  Future<void> _onFlip(CameraFlipRequested e, Emitter<CameraState> emit) async {
    if (_cameras.length < 2) return;
    await state.controller?.dispose();
    emit(state.copyWith(ready: false));
    final next = state.selectedCamera == 0 ? 1 : 0;
    await _startCamera(next, emit);
  }

  Future<void> _onFlash(CameraFlashToggled e, Emitter<CameraState> emit) async {
    final next = !state.flashOn;
    await state.controller?.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    emit(state.copyWith(flashOn: next));
  }

  void _onReset(CameraScanReset e, Emitter<CameraState> emit) {
    emit(state.copyWith(detected: false, clearDevice: true));
    _scheduleDetection();
  }

  void _onDetected(CameraDetected e, Emitter<CameraState> emit) =>
      emit(state.copyWith(detected: true, device: e.device));

  void _scheduleDetection() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!isClosed) {
        add(CameraDetected( DetectedDeviceModel(
          name: 'TP-Link Router', model: 'Archer C6', guideCount: 4,
          confidence: 82, accent: Color(0xFF00D2B4), icon: Icons.router_rounded,
        )));
      }
    });
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }
}