import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../cubit/recorder_cubit.dart';
import '../cubit/recorder_state.dart';
import '../molecules/success_card.dart';
import '../organisms/countdown_overlay.dart';
import '../organisms/recorder_controls.dart';
import '../organisms/drawing_toolbar.dart';

class RecorderHomePage extends StatefulWidget {
  const RecorderHomePage({super.key});

  @override
  State<RecorderHomePage> createState() => _RecorderHomePageState();
}

class _RecorderHomePageState extends State<RecorderHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<RecorderCubit>().checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RecorderCubit, RecorderState>(
        listener: (context, state) {
          if (state is RecorderFailure) {
            CustomSnackBar.show(
              context,
              message: 'Erreur : ${state.error}',
              isError: true,
            );
          } else if (state is RecorderSuccess) {
            CustomSnackBar.show(
              context,
              message: 'Enregistré dans la galerie !',
            );
          }
        },
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

          return Stack(
            children: [
              // Background
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

              // Settings Button
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      ),
                  icon: Icon(
                    Icons.settings_rounded,
                    color: onSurfaceColor,
                    size: 28,
                  ),
                  splashRadius: 24,
                ),
              ),

              // Drawing Toggle Button (only show when recording)
              if (state is RecorderRecording)
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    onPressed:
                        () => context.read<RecorderCubit>().toggleDrawing(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            state.isDrawingEnabled
                                ? Theme.of(context).colorScheme.primary
                                : onSurfaceColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color:
                            state.isDrawingEnabled
                                ? Colors.white
                                : onSurfaceColor,
                        size: 18,
                      ),
                    ),
                    splashRadius: 24,
                  ),
                ),

              // Main Content
              Center(
                child: Column(
                  children: [
                    Expanded(
                      child: RecorderControls(
                        isRecording: state is RecorderRecording,
                        onRecordTap: () {
                          if (state is RecorderRecording) {
                            context.read<RecorderCubit>().stopRecording();
                          } else if (state is RecorderInitial ||
                              state is RecorderSuccess ||
                              state is RecorderFailure) {
                            context.read<RecorderCubit>().prepareRecording();
                          }
                        },
                      ),
                    ),

                    // Last Recording Card
                    if (state is RecorderSuccess)
                      SuccessCard(
                        path: state.path,
                        onDismissed:
                            () => context.read<RecorderCubit>().reset(),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Countdown Overlay
              if (state is RecorderCountdown)
                CountdownOverlay(
                  count: state.count,
                  onSkip: () => context.read<RecorderCubit>().skipCountdown(),
                ),

              // Drawing Toolbar
              const DrawingToolbar(),
            ],
          );
        },
      ),
    );
  }
}
