import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.helpful_recorder/recorder',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.example.helpful_recorder/recorder_events',
  );

  Stream<String>? _recordingEventsStream;

  Stream<String> get recordingEvents {
    _recordingEventsStream ??= _eventChannel.receiveBroadcastStream().map(
      (event) => event.toString(),
    );
    return _recordingEventsStream!;
  }

  Future<bool> checkPermissions() async {
    await [
      Permission.storage,
      Permission.microphone,
      Permission.notification,
      Permission.systemAlertWindow,
      Permission.manageExternalStorage,
    ].request();

    // We don't need FlutterOverlayWindow permission anymore as we use native overlay
    return await Permission.microphone.isGranted &&
        await Permission.systemAlertWindow.isGranted;
  }

  Future<bool> prepareRecording() async {
    try {
      final bool? result = await _channel.invokeMethod('prepareRecording');
      return result ?? false;
    } on PlatformException catch (e) {
      log("Error preparing recording: $e");
      return false;
    }
  }

  Future<String> startRecording({
    required String fileName,
    required bool recordAudio,
    required String videoQuality,
    required bool showTouches,
  }) async {
    try {
      final String? result = await _channel.invokeMethod('startRecording', {
        'fileName': fileName,
        'recordAudio': recordAudio,
        'videoQuality': videoQuality,
        'showTouches': showTouches,
      });

      if (result != null) {
        log("Recording started: $fileName");
        return result;
      } else {
        throw Exception("Failed to start recording: null result");
      }
    } on PlatformException catch (e) {
      log("Error starting recording: $e");
      rethrow;
    }
  }

  Future<String> stopRecording() async {
    try {
      final String? path = await _channel.invokeMethod('stopRecording');
      log("Recording stopped: $path");
      return path ?? "";
    } catch (e) {
      log("Error stopping recording: $e");
      rethrow;
    }
  }

  Future<void> updateOverlayStyle({
    required int backgroundColor,
    required int panelColor,
    required int iconColor,
  }) async {
    try {
      await _channel.invokeMethod('updateOverlayStyle', {
        'backgroundColor': backgroundColor,
        'panelColor': panelColor,
        'iconColor': iconColor,
      });
    } catch (e) {
      log("Overlay style update failed: $e");
    }
  }
}
