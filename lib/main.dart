import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/recorder/data/datasources/recorder_service.dart';
import 'features/recorder/data/repositories/recorder_repository_impl.dart';
import 'features/recorder/presentation/cubit/recorder_cubit.dart';
import 'features/recorder/presentation/pages/recorder_home_page.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'overlay_widget.dart';

void main() {
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: OverlayWidget()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(
          create:
              (context) => RecorderCubit(
                RecorderRepositoryImpl(RecorderService()),
                context.read<SettingsCubit>(),
              ),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Enregistreur Utile',
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const RecorderHomePage(),
          );
        },
      ),
    );
  }
}
