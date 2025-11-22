import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../molecules/setting_tile.dart';
import '../molecules/switch_tile.dart';
import '../organisms/settings_section.dart';
import '../organisms/quality_picker_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isDark = state.themeMode == ThemeMode.dark;
        final primaryColor = Theme.of(context).colorScheme.primary;
        final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'PARAMÈTRES',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontSize: 16,
                color: onSurfaceColor,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: onSurfaceColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: onSurfaceColor,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: onSurfaceColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: onSurfaceColor,
                    size: 18,
                  ),
                ),
                onPressed:
                    () => context.read<SettingsCubit>().toggleTheme(!isDark),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              // Background Gradient (Same as Main Screen)
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors:
                        isDark
                            ? [const Color(0xFF2A2A2A), const Color(0xFF000000)]
                            : [
                              const Color(0xFFFFFFFF),
                              const Color(0xFFF5F5F5),
                            ],
                  ),
                ),
              ),

              // Content
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
                children: [
                  SettingsSection(
                    title: 'VIDÉO',
                    children: [
                      SettingTile(
                        icon: Icons.hd_rounded,
                        title: 'Qualité vidéo',
                        subtitle: _getQualityName(state.videoQuality),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: onSurfaceColor.withOpacity(0.3),
                        ),
                        onTap:
                            () =>
                                _showQualityPicker(context, state.videoQuality),
                        showDivider: true,
                      ),
                      SwitchTile(
                        icon: Icons.mic_rounded,
                        title: 'Enregistrer l\'audio',
                        subtitle: 'Inclure l\'audio du microphone',
                        value: state.recordAudio,
                        onChanged:
                            (val) =>
                                context.read<SettingsCubit>().toggleAudio(val),
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  SettingsSection(
                    title: 'CONTRÔLES',
                    children: [
                      SettingTile(
                        icon: Icons.timer_rounded,
                        title: 'Compte à rebours',
                        subtitle: '${state.countdownTime} secondes',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCountdownChip(
                              context,
                              3,
                              state.countdownTime,
                            ),
                            const SizedBox(width: 8),
                            _buildCountdownChip(
                              context,
                              5,
                              state.countdownTime,
                            ),
                            const SizedBox(width: 8),
                            _buildCountdownChip(
                              context,
                              10,
                              state.countdownTime,
                            ),
                          ],
                        ),
                        showDivider: true,
                      ),
                      SwitchTile(
                        icon: Icons.vibration_rounded,
                        title: 'Secouer pour arrêter',
                        subtitle: 'Secouer pour arrêter l\'enregistrement',
                        value: state.shakeToStop,
                        onChanged:
                            (val) => context
                                .read<SettingsCubit>()
                                .toggleShakeToStop(val),
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  SettingsSection(
                    title: 'STOCKAGE',
                    children: [
                      SettingTile(
                        icon: Icons.folder_open_rounded,
                        title: 'Emplacement de sauvegarde',
                        subtitle: '/Movies/HelpfulRecorder',
                        trailing: const SizedBox(),
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.videocam_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enregistreur Utile v1.0.0',
                          style: TextStyle(
                            color: onSurfaceColor.withOpacity(0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdownChip(
    BuildContext context,
    int seconds,
    int currentSelection,
  ) {
    final isSelected = currentSelection == seconds;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () => context.read<SettingsCubit>().setCountdownTime(seconds),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : onSurfaceColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          '${seconds}s',
          style: TextStyle(
            color: isSelected ? Colors.white : onSurfaceColor.withOpacity(0.5),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showQualityPicker(BuildContext context, VideoQuality currentQuality) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => QualityPickerSheet(
            currentQuality: currentQuality,
            onQualitySelected: (quality) {
              context.read<SettingsCubit>().setVideoQuality(quality);
              Navigator.pop(context);
            },
          ),
    );
  }

  String _getQualityName(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.high:
        return 'ÉLEVÉE';
      case VideoQuality.medium:
        return 'MOYENNE';
      case VideoQuality.low:
        return 'FAIBLE';
    }
  }
}
