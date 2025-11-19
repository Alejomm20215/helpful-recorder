import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../recorder_service.dart';
import 'recorder_state.dart';
import 'settings_cubit.dart';

class RecorderCubit extends Cubit<RecorderState> {
  final RecorderService _recorderService;
  final SettingsCubit _settingsCubit;
  Timer? _countdownTimer;
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _accelerometerSubscription;

  RecorderCubit(this._recorderService, this._settingsCubit) : super(RecorderInitial()) {
    _listenToRecordingEvents();
  }
  
  void _listenToRecordingEvents() {
    _eventsSubscription = _recorderService.recordingEvents.listen((event) {
      if (event.startsWith('RECORDING_STOPPED')) {
        // When native service stops recording, reset to initial state
        if (event.contains(':')) {
          final path = event.substring('RECORDING_STOPPED:'.length);
          emit(RecorderSuccess(path));
        } else {
          emit(RecorderInitial());
        }
        _stopAccelerometer();
      } else if (event == 'RECORDING_RESTART_REQUESTED') {
        // When restart is requested from native overlay, automatically start new recording with countdown
        emit(RecorderInitial());
        _stopAccelerometer();
        // Small delay to ensure UI updates, then start new recording
        Future.delayed(const Duration(milliseconds: 300), () {
          prepareRecording();
        });
      }
    });
  }

  void _startAccelerometer() {
    if (!_settingsCubit.state.shakeToStop) return;

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      double g = 9.8;
      double x = event.x;
      double y = event.y;
      double z = event.z;

      // Calculate total acceleration
      double gForce = sqrt(x * x + y * y + z * z) / g;

      // Threshold for shake (adjust as needed, 2.5 is a strong shake)
      if (gForce > 2.5) {
        stopRecording();
      }
    });
  }

  void _stopAccelerometer() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
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
        emit(const RecorderFailure("Screen recording was not allowed"));
      }
    } catch (e) {
      emit(RecorderFailure(e.toString()));
    }
  }

  void startCountdown() {
    int count = _settingsCubit.state.countdownTime;
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
      
      final settings = _settingsCubit.state;
      
      await _recorderService.startRecording(
        fileName: fileName,
        recordAudio: settings.recordAudio,
        videoQuality: settings.videoQuality.name,
        showTouches: false, // Removed feature
      );

      // Start shake detection if enabled
      _startAccelerometer();

    } catch (e) {
      emit(RecorderFailure(e.toString()));
    }
  }

  Future<void> stopRecording() async {
    try {
      _stopAccelerometer();
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
    _accelerometerSubscription?.cancel();
    return super.close();
  }
}
