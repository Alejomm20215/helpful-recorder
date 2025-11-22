import 'dart:ui';
import '../../domain/repositories/drawing_repository.dart';
import '../datasources/drawing_service.dart';

class DrawingRepositoryImpl implements DrawingRepository {
  final DrawingService _drawingService;

  DrawingRepositoryImpl(this._drawingService);

  @override
  Future<void> showDrawingOverlay() async {
    return await _drawingService.showDrawingOverlay();
  }

  @override
  Future<void> hideDrawingOverlay() async {
    return await _drawingService.hideDrawingOverlay();
  }

  @override
  Future<void> setDrawingColor(Color color) async {
    return await _drawingService.setDrawingColor(color);
  }

  @override
  Future<void> setDrawingWidth(double width) async {
    return await _drawingService.setDrawingWidth(width);
  }

  @override
  Future<void> clearDrawing() async {
    return await _drawingService.clearDrawing();
  }

  @override
  Future<void> undoDrawing() async {
    return await _drawingService.undoDrawing();
  }
}
