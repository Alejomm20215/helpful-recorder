import 'package:equatable/equatable.dart';

abstract class RecorderState extends Equatable {
  const RecorderState();

  @override
  List<Object?> get props => [];
}

class RecorderInitial extends RecorderState {}

class RecorderPermissionRequired extends RecorderState {}

class RecorderCountdown extends RecorderState {
  final int count;
  const RecorderCountdown(this.count);

  @override
  List<Object?> get props => [count];
}

class RecorderRecording extends RecorderState {
  final bool isDrawingEnabled;
  final int currentDrawingColor;

  const RecorderRecording({
    this.isDrawingEnabled = false,
    this.currentDrawingColor = 0xFFFF0000, // Red
  });

  RecorderRecording copyWith({
    bool? isDrawingEnabled,
    int? currentDrawingColor,
  }) {
    return RecorderRecording(
      isDrawingEnabled: isDrawingEnabled ?? this.isDrawingEnabled,
      currentDrawingColor: currentDrawingColor ?? this.currentDrawingColor,
    );
  }

  @override
  List<Object?> get props => [isDrawingEnabled, currentDrawingColor];
}

class RecorderSuccess extends RecorderState {
  final String path;
  const RecorderSuccess(this.path);

  @override
  List<Object?> get props => [path];
}

class RecorderFailure extends RecorderState {
  final String error;
  const RecorderFailure(this.error);

  @override
  List<Object?> get props => [error];
}
