import 'dart:ui';

abstract class DrawingRepository {
  Future<void> showDrawingOverlay();
  Future<void> hideDrawingOverlay();
  Future<void> setDrawingColor(Color color);
  Future<void> setDrawingWidth(double width);
  Future<void> clearDrawing();
  Future<void> undoDrawing();
}
