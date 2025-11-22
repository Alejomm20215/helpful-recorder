import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../domain/repositories/recorder_repository.dart';
import '../../domain/repositories/drawing_repository.dart';
import 'recorder_state.dart';
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';

class RecorderCubit extends Cubit<RecorderState> {
  final RecorderRepository _recorderRepository;
  final DrawingRepository _drawingRepository;
  final SettingsCubit _settingsCubit;
  Timer? _countdownTimer;
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _accelerometerSubscription;

  RecorderCubit(
    this._recorderRepository,
    this._drawingRepository,
    this._settingsCubit,
  ) : super(RecorderInitial()) {
    _listenToRecordingEvents();
  }

  void _listenToRecordingEvents() {
    _eventsSubscription = _recorderRepository.recordingEvents.listen((event) {
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
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
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
      final hasPermission = await _recorderRepository.checkPermissions();
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
    final hasPermission = await _recorderRepository.checkPermissions();
    if (!hasPermission) {
      emit(RecorderPermissionRequired());
      return;
    }

    await _recorderRepository.updateOverlayStyle(
      backgroundColor: 0xCC000000,
      panelColor: 0xFF1F1F1F,
      iconColor: 0xFFFFFFFF,
    );

    // 2. Ask for MediaProjection Permission (System Dialog)
    try {
      final ready = await _recorderRepository.prepareRecording();
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

      await _recorderRepository.startRecording(
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
      final path = await _recorderRepository.stopRecording();
      emit(RecorderSuccess(path));
    } catch (e) {
      emit(RecorderFailure(e.toString()));
    }
  }

  void reset() {
    emit(RecorderInitial());
  }

  // Drawing methods
  Future<void> toggleDrawing() async {
    if (state is RecorderRecording) {
      final currentState = state as RecorderRecording;
      final newDrawingState = !currentState.isDrawingEnabled;

      if (newDrawingState) {
        await _drawingRepository.showDrawingOverlay();
      } else {
        await _drawingRepository.hideDrawingOverlay();
      }

      emit(currentState.copyWith(isDrawingEnabled: newDrawingState));
    }
  }

  Future<void> setDrawingColor(int color) async {
    if (state is RecorderRecording) {
      final currentState = state as RecorderRecording;
      await _drawingRepository.setDrawingColor(Color(color));
      emit(currentState.copyWith(currentDrawingColor: color));
    }
  }

  Future<void> setDrawingWidth(double width) async {
    await _drawingRepository.setDrawingWidth(width);
  }

  Future<void> clearDrawing() async {
    await _drawingRepository.clearDrawing();
  }

  Future<void> undoDrawing() async {
    await _drawingRepository.undoDrawing();
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _eventsSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    // Hide drawing overlay if active
    if (state is RecorderRecording) {
      final currentState = state as RecorderRecording;
      if (currentState.isDrawingEnabled) {
        _drawingRepository.hideDrawingOverlay();
      }
    }
    return super.close();
  }
}
