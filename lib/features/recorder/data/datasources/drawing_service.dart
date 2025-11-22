import 'dart:developer';
import 'dart:ui';
import 'package:flutter/services.dart';

class DrawingService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.helpful_recorder/recorder',
  );

  Future<void> showDrawingOverlay() async {
    try {
      await _channel.invokeMethod('showDrawingOverlay');
      log("Drawing overlay shown");
    } on PlatformException catch (e) {
      log("Error showing drawing overlay: $e");
      rethrow;
    }
  }

  Future<void> hideDrawingOverlay() async {
    try {
      await _channel.invokeMethod('hideDrawingOverlay');
      log("Drawing overlay hidden");
    } on PlatformException catch (e) {
      log("Error hiding drawing overlay: $e");
      rethrow;
    }
  }

  Future<void> setDrawingColor(Color color) async {
    try {
      await _channel.invokeMethod('setDrawingColor', {'color': color.value});
      log("Drawing color set to: ${color.value}");
    } on PlatformException catch (e) {
      log("Error setting drawing color: $e");
      rethrow;
    }
  }

  Future<void> setDrawingWidth(double width) async {
    try {
      await _channel.invokeMethod('setDrawingWidth', {'width': width});
      log("Drawing width set to: $width");
    } on PlatformException catch (e) {
      log("Error setting drawing width: $e");
      rethrow;
    }
  }

  Future<void> clearDrawing() async {
    try {
      await _channel.invokeMethod('clearDrawing');
      log("Drawing cleared");
    } on PlatformException catch (e) {
      log("Error clearing drawing: $e");
      rethrow;
    }
  }

  Future<void> undoDrawing() async {
    try {
      await _channel.invokeMethod('undoDrawing');
      log("Drawing undo");
    } on PlatformException catch (e) {
      log("Error undoing drawing: $e");
      rethrow;
    }
  }
}
