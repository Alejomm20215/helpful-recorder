import 'package:flutter/material.dart';

class CountdownOverlay extends StatelessWidget {
  final int count;
  final VoidCallback onSkip;

  const CountdownOverlay({
    super.key,
    required this.count,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: (isDark ? Colors.black : Colors.white).withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // Animated Number with Circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing Circle
                TweenAnimationBuilder<double>(
                  key: ValueKey(count), // Restart animation on count change
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(
                    milliseconds: 900,
                  ), // Slightly longer to fill the second
                  curve: Curves.easeOutQuad,
                  builder: (context, value, child) {
                    return Container(
                      width: 250 + (value * 50), // Expand size slightly
                      height: 250 + (value * 50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: onSurfaceColor.withOpacity(
                            0.3 * (1 - value),
                          ), // Fade out
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
                // Number
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder:
                      (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.5,
                            end: 1.0,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                  child: Text(
                    '$count',
                    key: ValueKey(count),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w200, // Thinner font
                      color: onSurfaceColor,
                      letterSpacing: -5,
                      shadows: [Shadow(color: primaryColor, blurRadius: 20)],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Skip Button
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: onSurfaceColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: onSurfaceColor.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: onSurfaceColor.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "PASSER",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                        color: onSurfaceColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.skip_next_rounded,
                      size: 18,
                      color: onSurfaceColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
