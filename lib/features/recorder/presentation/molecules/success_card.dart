import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class SuccessCard extends StatelessWidget {
  final String path;
  final VoidCallback onDismissed;

  const SuccessCard({super.key, required this.path, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Dismissible(
      key: const Key('success_card'),
      direction: DismissDirection.endToStart, // Swipe from right to left
      onDismissed: (direction) => onDismissed(),
      background: const SizedBox.shrink(), // No background visual feedback
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
          ),
          boxShadow:
              isDark
                  ? []
                  : [
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
                    'Enregistrement sauvegardé',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: onSurfaceColor,
                    ),
                  ),
                  Text(
                    'Appuyer pour ouvrir • Glisser pour fermer',
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurfaceColor.withOpacity(0.5),
                    ),
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
      ),
    );
  }
}
