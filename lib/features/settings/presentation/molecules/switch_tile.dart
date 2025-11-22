import 'package:flutter/material.dart';
import '../atoms/setting_icon.dart';
import '../atoms/setting_label.dart';

class SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const SwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              SettingIcon(icon: icon),
              const SizedBox(width: 16),
              Expanded(child: SettingLabel(title: title, subtitle: subtitle)),
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
}
