import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'features/recorder/data/datasources/recorder_service.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  bool _isExpanded = false;
  final RecorderService _recorderService = RecorderService();

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      log("Current Event: $event");
    });
  }

  void _stopRecording() async {
    // We need to communicate back to the main isolate to stop recording.
    // But since we have a custom recorder service that uses MethodChannel,
    // we can try calling it from here IF the plugin supports background execution properly.
    // However, the best way is to use the port.

    // For MVP with custom native code, the MethodChannel 'com.example.helpful_recorder/recorder'
    // needs to be registered in the isolate this overlay runs in.
    // The 'flutter_overlay_window' might run in a separate engine.
    // So standard MethodChannels might not reach the SAME Main Activity/Service instance
    // unless our native code handles it globally.

    // Our ScreenRecorderService.kt is a Service.
    // The MethodChannel in MainActivity communicates with MainActivity.
    // We need to make sure we can stop the service from here.

    // Let's try to invoke the method directly. If it fails, we use Isolate ports.
    try {
      // Actually, stopping the service via intent is easier from native side.
      // Let's send a message to native side via our EXISTING channel if possible,
      // or use the overlay plugin's mechanism to share data.

      // The flutter_overlay_window allows sharing data via shareData.
      // But triggering an action in the main app is different.

      // Simplest for MVP: Call the stop method on our RecorderService.
      // Since it uses MethodChannel, it talks to the Engine it's attached to.
      // The Overlay has its own Engine.
      // So we need our Native Kotlin code to handle the MethodChannel from ANY Engine.

      await _recorderService.stopRecording();
      // Close overlay
      await FlutterOverlayWindow.closeOverlay();
    } catch (e) {
      log("Error stopping from overlay: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _isExpanded ? _buildExpanded() : _buildCollapsed(),
    );
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
        FlutterOverlayWindow.resizeOverlay(300, 100, true); // Expand
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1),
          ],
        ),
        child: const Center(
          child: Icon(Icons.videocam, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildExpanded() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _isExpanded = false;
              });
              FlutterOverlayWindow.resizeOverlay(60, 60, true); // Collapse
            },
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: _stopRecording,
            icon: const Icon(Icons.stop, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

// Entry point for the overlay
@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: OverlayWidget()),
  );
}
