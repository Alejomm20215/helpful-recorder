import 'package:flutter/material.dart';
import '../atoms/record_button.dart';
import '../atoms/status_text.dart';

class RecorderControls extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onRecordTap;

  const RecorderControls({
    super.key,
    required this.isRecording,
    required this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),

        // Status Text
        StatusText(isRecording: isRecording),

        const SizedBox(height: 60),

        // Main Button
        RecordButton(isRecording: isRecording, onTap: onRecordTap),

        const SizedBox(height: 30),

        if (!isRecording)
          Text(
            'Appuyer pour enregistrer',
            style: TextStyle(color: onSurfaceColor.withOpacity(0.4)),
          ),

        const Spacer(),
      ],
    );
  }
}
