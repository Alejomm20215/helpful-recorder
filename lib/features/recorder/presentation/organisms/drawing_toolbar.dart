import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/recorder_cubit.dart';
import '../cubit/recorder_state.dart';

class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecorderCubit, RecorderState>(
      builder: (context, state) {
        if (state is! RecorderRecording || !state.isDrawingEnabled) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color Picker Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildColorButton(context, Colors.red, 0xFFFF0000),
                      _buildColorButton(context, Colors.blue, 0xFF0000FF),
                      _buildColorButton(context, Colors.green, 0xFF00FF00),
                      _buildColorButton(context, Colors.yellow, 0xFFFFFF00),
                      _buildColorButton(context, Colors.white, 0xFFFFFFFF),
                      _buildColorButton(context, Colors.black, 0xFF000000),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Size Selector Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSizeButton(context, 5, 20),
                      _buildSizeButton(context, 15, 28),
                      _buildSizeButton(context, 30, 36),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action Buttons Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        context,
                        Icons.undo,
                        'Annuler',
                        () => context.read<RecorderCubit>().undoDrawing(),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        Icons.delete_outline,
                        'Effacer',
                        () => context.read<RecorderCubit>().clearDrawing(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorButton(BuildContext context, Color color, int colorValue) {
    return GestureDetector(
      onTap: () => context.read<RecorderCubit>().setDrawingColor(colorValue),
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
        ),
      ),
    );
  }

  Widget _buildSizeButton(BuildContext context, double width, double size) {
    return GestureDetector(
      onTap: () => context.read<RecorderCubit>().setDrawingWidth(width),
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isDark ? Colors.white : Colors.black),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
