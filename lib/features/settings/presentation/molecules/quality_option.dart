import 'package:flutter/material.dart';
import '../cubit/settings_state.dart';

class QualityOption extends StatelessWidget {
  final VideoQuality quality;
  final VideoQuality currentQuality;
  final VoidCallback onTap;

  const QualityOption({
    super.key,
    required this.quality,
    required this.currentQuality,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = quality == currentQuality;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? primaryColor.withOpacity(0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color:
                    isSelected ? primaryColor : onSurfaceColor.withOpacity(0.3),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                _getQualityName(quality),
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

  String _getQualityName(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.high:
        return 'ÉLEVÉE (1080p)';
      case VideoQuality.medium:
        return 'MOYENNE (720p)';
      case VideoQuality.low:
        return 'FAIBLE (480p)';
    }
  }
}
