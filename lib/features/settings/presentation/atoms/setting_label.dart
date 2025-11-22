import 'package:flutter/material.dart';

class SettingLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const SettingLabel({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Column(
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
    );
  }
}
