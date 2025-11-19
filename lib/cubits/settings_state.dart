import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum VideoQuality { high, medium, low }

class SettingsState extends Equatable {
  final VideoQuality videoQuality;
  final bool recordAudio;
  final int countdownTime;
  final bool shakeToStop;
  final ThemeMode themeMode;

  const SettingsState({
    this.videoQuality = VideoQuality.high,
    this.recordAudio = true,
    this.countdownTime = 5,
    this.shakeToStop = false,
    this.themeMode = ThemeMode.dark,
  });

  SettingsState copyWith({
    VideoQuality? videoQuality,
    bool? recordAudio,
    int? countdownTime,
    bool? shakeToStop,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      videoQuality: videoQuality ?? this.videoQuality,
      recordAudio: recordAudio ?? this.recordAudio,
      countdownTime: countdownTime ?? this.countdownTime,
      shakeToStop: shakeToStop ?? this.shakeToStop,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [
        videoQuality,
        recordAudio,
        countdownTime,
        shakeToStop,
        themeMode,
      ];
}

