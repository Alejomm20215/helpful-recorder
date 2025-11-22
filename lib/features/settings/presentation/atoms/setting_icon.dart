import 'package:flutter/material.dart';

class SettingIcon extends StatelessWidget {
  final IconData icon;

  const SettingIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: primaryColor, size: 20),
    );
  }
}
