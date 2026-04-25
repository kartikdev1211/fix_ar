import 'package:flutter/material.dart';

class DetectedDeviceModel {
  final String name,model;
  final int guideCount, confidence;
  final Color accent;
  final IconData icon;

  DetectedDeviceModel({required this.name, required this.model, required this.guideCount, required this.confidence, required this.accent, required this.icon});
}
class ARLabel{
  final String text;
  final Color color;
  final Offset position;
  const ARLabel({required this.text, required this.color, required this.position});
}