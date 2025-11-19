import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'cubits/recorder_cubit.dart';
import 'cubits/recorder_state.dart';
import 'cubits/settings_cubit.dart';
import 'cubits/settings_state.dart';
import 'overlay_widget.dart';
import 'recorder_service.dart';
import 'widgets/custom_snackbar.dart';
import 'settings_page.dart';

void main() {
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayWidget(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return BlocProvider(
            create: (context) => RecorderCubit(
              RecorderService(),
              context.read<SettingsCubit>(),
            ),
            child: MaterialApp(
              title: 'Helpful Recorder',
              debugShowCheckedModeBanner: false,
              themeMode: state.themeMode,
              theme: ThemeData.light().copyWith(
                scaffoldBackgroundColor: const Color(0xFFF5F5F5),
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFFF3B30), // Red
                  secondary: Color(0xFFFFFFFF), // White
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: const Color(0xFF000000),
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFFF3B30), // Red
                  secondary: Color(0xFFFFFFFF), // White
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ),
                useMaterial3: true,
              ),
              home: const RecorderHomePage(),
            ),
          );
        },
      ),
    );
  }
}

class RecorderHomePage extends StatefulWidget {
  const RecorderHomePage({super.key});

  @override
  State<RecorderHomePage> createState() => _RecorderHomePageState();
}

class _RecorderHomePageState extends State<RecorderHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    context.read<RecorderCubit>().checkPermissions();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RecorderCubit, RecorderState>(
        listener: (context, state) {
          if (state is RecorderFailure) {
            CustomSnackBar.show(context, message: 'Error: ${state.error}', isError: true);
          } else if (state is RecorderSuccess) {
            CustomSnackBar.show(context, message: 'Saved to Gallery!');
          }
        },
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final primaryColor = Theme.of(context).colorScheme.primary;
          final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
          
          return Stack(
            children: [
              // Background
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

              // Settings Button
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  ),
                  icon: Icon(
                    Icons.settings_rounded,
                    color: onSurfaceColor,
                    size: 28,
                  ),
                  splashRadius: 24,
                ),
              ),

              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // Status Text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        state is RecorderRecording ? 'RECORDING' : 'READY',
                        key: ValueKey(state.runtimeType),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: state is RecorderRecording ? primaryColor : onSurfaceColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 60),

                    // Main Button
                    GestureDetector(
                      onTap: () {
                        if (state is RecorderRecording) {
                          context.read<RecorderCubit>().stopRecording();
                        } else if (state is RecorderInitial || state is RecorderSuccess || state is RecorderFailure) {
                          context.read<RecorderCubit>().prepareRecording();
                        }
                      },
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          final isRecording = state is RecorderRecording;
                          final scale = isRecording ? _pulseAnimation.value : 1.0;
                          
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isRecording ? primaryColor : (isDark ? Colors.white : primaryColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isRecording ? primaryColor : (isDark ? Colors.white : primaryColor)).withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                  child: Icon(
                                    isRecording ? Icons.stop_rounded : Icons.circle,
                                    key: ValueKey(isRecording),
                                    size: 50,
                                    color: isRecording ? Colors.white : (isDark ? primaryColor : Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    if (state is! RecorderRecording && state is! RecorderCountdown)
                      Text(
                        'Tap to Record',
                        style: TextStyle(color: onSurfaceColor.withOpacity(0.4)),
                      ),

                    const Spacer(),

                    // Last Recording Card
                    if (state is RecorderSuccess)
                      _buildSuccessCard(context, state.path),
                      
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Countdown Overlay
              if (state is RecorderCountdown)
                _buildCountdownOverlay(context, state.count),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuccessCard(BuildContext context, String path) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.play_arrow_rounded, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recording Saved',
                  style: TextStyle(fontWeight: FontWeight.bold, color: onSurfaceColor),
                ),
                Text(
                  'Gallery/Movies/HelpfulRecorder',
                  style: TextStyle(fontSize: 12, color: onSurfaceColor.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.open_in_new_rounded, color: onSurfaceColor),
            onPressed: () => OpenFile.open(path),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay(BuildContext context, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: (isDark ? Colors.black : Colors.white).withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // Animated Number with Circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing Circle
                TweenAnimationBuilder<double>(
                  key: ValueKey(count), // Restart animation on count change
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 900), // Slightly longer to fill the second
                  curve: Curves.easeOutQuad,
                  builder: (context, value, child) {
                    return Container(
                      width: 250 + (value * 50), // Expand size slightly
                      height: 250 + (value * 50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: onSurfaceColor.withOpacity(0.3 * (1 - value)), // Fade out
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
                // Number
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.5, end: 1.0).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    '$count',
                    key: ValueKey(count),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w200, // Thinner font
                      color: onSurfaceColor,
                      letterSpacing: -5,
                      shadows: [
                        Shadow(color: primaryColor, blurRadius: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Skip Button
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: TextButton(
                onPressed: () => context.read<RecorderCubit>().skipCountdown(),
                style: TextButton.styleFrom(
                  foregroundColor: onSurfaceColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: onSurfaceColor.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: onSurfaceColor.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SKIP", 
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600, 
                        letterSpacing: 3,
                        color: onSurfaceColor,
                      )
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.skip_next_rounded, size: 18, color: onSurfaceColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
