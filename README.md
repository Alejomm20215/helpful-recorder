# Helpful Recorder

Modern Android screen recording app built with Flutter and native Android APIs. Clean UI, powerful features, zero bloat.

## Features

### Recording
- Screen capture with configurable video quality (1080p/720p/480p)
- Audio recording toggle (microphone input)
- Custom countdown timer (3s/5s/10s)
- Hardware-accelerated encoding (H.264/AAC)

### Controls
- Floating overlay with drag-to-reposition
- Stop/Pause/Resume/Restart controls
- Double-tap to hide overlay
- Shake-to-stop gesture
- Touch visualization

### UI/UX
- Glassmorphism design with radial gradients
- Dark/Light theme with system adaptation
- Material Design 3 components
- Responsive layout for all screen sizes

## Quick Start

```bash
git clone <repository-url>
cd helpful_recorder
flutter pub get
flutter run
```

## Usage

1. **Grant Permissions**: Audio, Storage, Overlay, Media Projection
2. **Configure Settings**: Quality, countdown, audio, gestures
3. **Start Recording**: Tap record → wait for countdown → overlay appears
4. **Control**: Use floating overlay or shake gesture to stop
5. **Access**: Videos saved to `/Movies/HelpfulRecorder/`

## Settings

| Setting | Options | Default |
|---------|---------|---------|
| Video Quality | High/Medium/Low | High |
| Record Audio | On/Off | On |
| Countdown | 3s/5s/10s | 5s |
| Shake to Stop | On/Off | Off |
| Show Touches | On/Off | Off |
| Theme | Dark/Light | System |

## Architecture

### Flutter Layer
- **BLoC Pattern**: State management for recording and settings
- **Platform Channels**: Bidirectional communication with Android
- **SharedPreferences**: Persistent user preferences
- **Sensors API**: Accelerometer for shake detection

### Android Layer
- **MediaProjection API**: Screen capture authorization
- **MediaRecorder**: Hardware-accelerated encoding
- **Foreground Service**: Background recording with notification
- **WindowManager**: System overlay for controls
- **MediaStore**: Modern file storage (Android 10+)

## Technical Specs

- **Minimum SDK**: API 24 (Android 7.0)
- **Target SDK**: API 34 (Android 14)
- **Kotlin Version**: 2.1.0
- **Flutter Version**: 3.19+

## Permissions

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION"/>
```

## Build & Deploy

### Debug
```bash
flutter run
```

### Release APK
```bash
flutter build apk --release
```

### Bundle Analysis
```bash
flutter build apk --analyze-size
```

## File Structure

```
lib/
├── cubits/                 # BLoC state management
│   ├── recorder_cubit.dart # Recording logic
│   ├── settings_cubit.dart # App preferences
│   └── settings_state.dart # Settings model
├── widgets/                # Reusable components
│   └── custom_snackbar.dart # Styled notifications
├── main.dart               # App entry point
├── settings_page.dart      # Settings UI
└── recorder_service.dart   # Platform interface

android/
├── app/src/main/kotlin/
│   └── com/example/helpful_recorder/
│       ├── MainActivity.kt      # Flutter bridge
│       └── ScreenRecorderService.kt # Native recording
└── app/src/main/res/       # Android resources
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^9.1.1
  shared_preferences: ^2.5.3
  sensors_plus: ^7.0.0
  permission_handler: ^12.0.1
  open_file: ^3.5.10
  video_player: ^2.10.1
```

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

**Built with Flutter & Kotlin**
