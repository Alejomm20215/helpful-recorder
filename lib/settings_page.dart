import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/settings_cubit.dart';
import 'cubits/settings_state.dart';

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
              'SETTINGS',
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
                child: Icon(Icons.arrow_back_ios_new_rounded, color: onSurfaceColor, size: 18),
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
                onPressed: () => context.read<SettingsCubit>().toggleTheme(!isDark),
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
                    colors: isDark 
                      ? [const Color(0xFF2A2A2A), const Color(0xFF000000)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFF5F5F5)],
                  ),
                ),
              ),

              // Content
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
                children: [
                  _buildSectionHeader(context, 'VIDEO'),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.hd_rounded,
                        title: 'Video Quality',
                        subtitle: state.videoQuality.name.toUpperCase(),
                        trailing: Icon(Icons.chevron_right_rounded, color: onSurfaceColor.withOpacity(0.3)),
                        onTap: () => _showQualityPicker(context, state.videoQuality),
                        showDivider: true,
                      ),
                      _buildSwitchTile(
                        context,
                        icon: Icons.mic_rounded,
                        title: 'Record Audio',
                        subtitle: 'Include microphone audio',
                        value: state.recordAudio,
                        onChanged: (val) => context.read<SettingsCubit>().toggleAudio(val),
                        showDivider: true,
                      ),
                      _buildSwitchTile(
                        context,
                        icon: Icons.touch_app_rounded,
                        title: 'Show Touches',
                        subtitle: 'Display touch indicators while recording',
                        value: state.showTouches,
                        onChanged: (val) => context.read<SettingsCubit>().toggleShowTouches(val),
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'CONTROLS'),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.timer_rounded,
                        title: 'Countdown',
                        subtitle: '${state.countdownTime} seconds',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCountdownChip(context, 3, state.countdownTime),
                            const SizedBox(width: 8),
                            _buildCountdownChip(context, 5, state.countdownTime),
                            const SizedBox(width: 8),
                            _buildCountdownChip(context, 10, state.countdownTime),
                          ],
                        ),
                        showDivider: true,
                      ),
                      _buildSwitchTile(
                        context,
                        icon: Icons.vibration_rounded,
                        title: 'Shake to Stop',
                        subtitle: 'Shake device to stop recording',
                        value: state.shakeToStop,
                        onChanged: (val) => context.read<SettingsCubit>().toggleShakeToStop(val),
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'STORAGE'),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.folder_open_rounded,
                        title: 'Save Location',
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
                          child: Icon(Icons.videocam_rounded, color: primaryColor, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Helpful Recorder v1.0.0',
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

  Widget _buildGlassCard(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: onSurfaceColor.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 20,
            color: onSurfaceColor.withOpacity(0.05),
          ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: onSurfaceColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: onSurfaceColor.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: primaryColor,
                activeTrackColor: primaryColor.withOpacity(0.3),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: onSurfaceColor.withOpacity(0.1),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 20,
            color: onSurfaceColor.withOpacity(0.05),
          ),
      ],
    );
  }

  Widget _buildCountdownChip(BuildContext context, int seconds, int currentSelection) {
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
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: onSurfaceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'VIDEO QUALITY',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 2,
                color: onSurfaceColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            ...VideoQuality.values.map((q) => _buildQualityOption(context, q, currentQuality)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(BuildContext context, VideoQuality quality, VideoQuality current) {
    final isSelected = quality == current;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<SettingsCubit>().setVideoQuality(quality);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? primaryColor : onSurfaceColor.withOpacity(0.3),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                quality.name.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? primaryColor : onSurfaceColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_rounded, color: primaryColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
