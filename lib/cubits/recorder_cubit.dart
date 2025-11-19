import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../recorder_service.dart';
import 'recorder_state.dart';

class RecorderCubit extends Cubit<RecorderState> {
  final RecorderService _recorderService;
  Timer? _countdownTimer;
  StreamSubscription? _eventsSubscription;

  RecorderCubit(this._recorderService) : super(RecorderInitial()) {
    _listenToRecordingEvents();
  }
  
  void _listenToRecordingEvents() {
    _eventsSubscription = _recorderService.recordingEvents.listen((event) {
      if (event == 'RECORDING_STOPPED') {
        // When native service stops recording, reset to initial state
        emit(RecorderInitial());
      } else if (event == 'RECORDING_RESTART_REQUESTED') {
        // When restart is requested from native overlay, automatically start new recording with countdown
        emit(RecorderInitial());
        // Small delay to ensure UI updates, then start new recording
        Future.delayed(const Duration(milliseconds: 300), () {
          prepareRecording();
        });
      }
    });
  }

  Future<void> checkPermissions() async {
    try {
      final hasPermission = await _recorderService.checkPermissions();
      if (hasPermission) {
        emit(RecorderInitial());
      } else {
        emit(RecorderPermissionRequired());
      }
    } catch (e) {
      emit(RecorderFailure(e.toString()));
    }
  }

  void prepareRecording() async {
    // 1. Ask for permission FIRST
    final hasPermission = await _recorderService.checkPermissions();
    if (!hasPermission) {
      emit(RecorderPermissionRequired());
      return;
    }

    await _recorderService.updateOverlayStyle(
      backgroundColor: 0xCC000000,
      panelColor: 0xFF1F1F1F,
      iconColor: 0xFFFFFFFF,
    );

    // 2. Ask for MediaProjection Permission (System Dialog)
    try {
      final ready = await _recorderService.prepareRecording();
      if (ready) {
        // 3. If accepted, START COUNTDOWN
        startCountdown();
      } else {
        // User denied system dialog
        emit(const RecorderFailure("Screen recording permission denied by user"));
      }
    } catch (e) {
      emit(RecorderFailure(e.toString()));
    }
  }

  void startCountdown() {
    int count = 5;
    emit(RecorderCountdown(count));

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count--;
      if (count > 0) {
        emit(RecorderCountdown(count));
      } else {
        timer.cancel();
        startRecording();
      }
    });
  }

  void skipCountdown() {
    _countdownTimer?.cancel();
    startRecording();
  }

  Future<void> startRecording() async {
    try {
      emit(RecorderRecording());
      
      // Start Native Recording (Permission already granted in prepare step)
      String fileName = "Rec_${DateTime.now().millisecondsSinceEpoch}";
      await _recorderService.startRecording(fileName: fileName);

      // Overlay is handled natively now

    } catch (e) {
      emit(RecorderFailure(e.toString()));
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _recorderService.stopRecording();
      emit(RecorderSuccess(path));
    } catch (e) {
      emit(RecorderFailure(e.toString()));
    }
  }
  
  void reset() {
    emit(RecorderInitial());
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _eventsSubscription?.cancel();
    return super.close();
  }
}
