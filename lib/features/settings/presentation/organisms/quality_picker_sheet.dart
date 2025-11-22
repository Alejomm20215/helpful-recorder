import 'package:flutter/material.dart';
import '../cubit/settings_state.dart';
import '../molecules/quality_option.dart';

class QualityPickerSheet extends StatelessWidget {
  final VideoQuality currentQuality;
  final ValueChanged<VideoQuality> onQualitySelected;

  const QualityPickerSheet({
    super.key,
    required this.currentQuality,
    required this.onQualitySelected,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
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
            'QUALITÉ VIDÉO',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 2,
              color: onSurfaceColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ...VideoQuality.values.map(
            (q) => QualityOption(
              quality: q,
              currentQuality: currentQuality,
              onTap: () => onQualitySelected(q),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
