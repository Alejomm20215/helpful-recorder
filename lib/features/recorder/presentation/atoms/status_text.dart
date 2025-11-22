import 'package:flutter/material.dart';

class StatusText extends StatelessWidget {
  final bool isRecording;

  const StatusText({super.key, required this.isRecording});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        isRecording ? 'ENREGISTREMENT' : 'PRÊT',
        key: ValueKey(isRecording),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          color: isRecording ? primaryColor : onSurfaceColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
