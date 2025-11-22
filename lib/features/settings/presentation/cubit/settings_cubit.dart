import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final qualityIndex = prefs.getInt('videoQuality') ?? 0;
      final recordAudio = prefs.getBool('recordAudio') ?? true;
      final countdownTime = prefs.getInt('countdownTime') ?? 5;
      final shakeToStop = prefs.getBool('shakeToStop') ?? false;
      final isDarkMode = prefs.getBool('isDarkMode') ?? true;

      emit(
        SettingsState(
          videoQuality: VideoQuality.values[qualityIndex],
          recordAudio: recordAudio,
          countdownTime: countdownTime,
          shakeToStop: shakeToStop,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        ),
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Fallback to default state if SharedPreferences fails
      emit(const SettingsState());
    }
  }

  Future<void> setVideoQuality(VideoQuality quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('videoQuality', quality.index);
    emit(state.copyWith(videoQuality: quality));
  }

  Future<void> toggleAudio(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('recordAudio', value);
    emit(state.copyWith(recordAudio: value));
  }

  Future<void> setCountdownTime(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('countdownTime', seconds);
    emit(state.copyWith(countdownTime: seconds));
  }

  Future<void> toggleShakeToStop(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shakeToStop', value);
    emit(state.copyWith(shakeToStop: value));
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }
}
