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

class RecorderRecording extends RecorderState {}

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
