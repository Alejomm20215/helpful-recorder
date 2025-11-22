abstract class RecorderRepository {
  Stream<String> get recordingEvents;
  Future<bool> checkPermissions();
  Future<bool> prepareRecording();
  Future<String> startRecording({
    required String fileName,
    required bool recordAudio,
    required String videoQuality,
    required bool showTouches,
  });
  Future<String> stopRecording();
  Future<void> updateOverlayStyle({
    required int backgroundColor,
    required int panelColor,
    required int iconColor,
  });
}
