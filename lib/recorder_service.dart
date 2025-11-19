import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:ed_screen_recorder/ed_screen_recorder.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderService {
  final EdScreenRecorder _recorder = EdScreenRecorder();
  bool _isRecording = false;
  
  bool get isRecording => _isRecording;

  Future<bool> startRecording({required String fileName, bool audioEnable = true}) async {
    try {
      // Solicitar permisos primero
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.microphone,
      ].request();

      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        log("Microphone permission denied");
        return false;
      }

      // Obtener directorio
      Directory? tempDir = await getExternalStorageDirectory(); // Android specific
      String? dirPath = tempDir?.path;
      
      if (dirPath == null) {
        log("Could not get storage directory");
        return false;
      }

      var response = await _recorder.startRecordScreen(
        fileName: fileName,
        dirPathToSave: dirPath,
        audioEnable: audioEnable,
        width: 720, // Default width
        height: 1280, // Default height
        videoBitrate: 3000000,
        videoFrame: 30,
      );
      
      log("Start record response: $response");
      _isRecording = true;
      return true;
    } on PlatformException catch (e) {
      log("Error starting record: ${e.message}");
      _isRecording = false;
      return false;
    } catch (e) {
      log("Unexpected error: $e");
      _isRecording = false;
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      var response = await _recorder.stopRecord();
      log("Stop record response: $response");
      _isRecording = false;
      
      // La respuesta suele ser un mapa o un objeto con 'file' o 'success'
      // ed_screen_recorder devuelve un Map<String, dynamic> o similar en versiones recientes
      // Revisando la implementación típica, response['file'] suele ser el path
       if (response is Map && response.containsKey('file')) {
         return response['file'] as String;
       }
       // Fallback si devuelve solo el path como string (versiones antiguas) o estructura diferente
       return response.toString();
       
    } catch (e) {
      log("Error stopping record: $e");
      _isRecording = false;
      return null;
    }
  }
}

