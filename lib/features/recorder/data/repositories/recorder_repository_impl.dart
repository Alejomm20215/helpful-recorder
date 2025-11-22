import '../../data/datasources/recorder_service.dart';
import '../../domain/repositories/recorder_repository.dart';

class RecorderRepositoryImpl implements RecorderRepository {
  final RecorderService _service;

  RecorderRepositoryImpl(this._service);

  @override
  Stream<String> get recordingEvents => _service.recordingEvents;

  @override
  Future<bool> checkPermissions() => _service.checkPermissions();

  @override
  Future<bool> prepareRecording() => _service.prepareRecording();

  @override
  Future<String> startRecording({
    required String fileName,
    required bool recordAudio,
    required String videoQuality,
    required bool showTouches,
  }) {
    return _service.startRecording(
      fileName: fileName,
      recordAudio: recordAudio,
      videoQuality: videoQuality,
      showTouches: showTouches,
    );
  }

  @override
  Future<String> stopRecording() => _service.stopRecording();

  @override
  Future<void> updateOverlayStyle({
    required int backgroundColor,
    required int panelColor,
    required int iconColor,
  }) {
    return _service.updateOverlayStyle(
      backgroundColor: backgroundColor,
      panelColor: panelColor,
      iconColor: iconColor,
    );
  }
}
