import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:alerta_mobile/core/services/cloud_storage_service.dart';

class RecorderService {
  CameraController? _cameraController;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final CloudStorageService _cloudStorage = CloudStorageService();
  
  bool _isRecordingVideo = false;
  bool _isRecordingAudio = false;

  bool get isRecording => _isRecordingVideo || _isRecordingAudio;
  CameraController? get cameraController => _cameraController;

  Future<void> initialize() async {
    // Initialize Camera
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras[0], // Use back camera
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await _cameraController!.initialize();
    }
  }

  Future<String?> startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await initialize();
    }

    if (_cameraController != null && !_isRecordingVideo) {
      try {
        await _cameraController!.startVideoRecording();
        _isRecordingVideo = true;
        return 'Video Recording Started';
      } catch (e) {
        return 'Error starting video: $e';
      }
    }
    return null;
  }

  Future<File?> stopVideoRecording() async {
    if (_cameraController != null && _isRecordingVideo) {
      try {
        final XFile file = await _cameraController!.stopVideoRecording();
        _isRecordingVideo = false;
        return File(file.path);
      } catch (e) {
        print('Error stopping video: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> startAudioRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final String path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _audioRecorder.start(const RecordConfig(), path: path);
      _isRecordingAudio = true;
    }
  }

  Future<String?> stopAudioRecording() async {
    if (_isRecordingAudio) {
      final path = await _audioRecorder.stop();
      _isRecordingAudio = false;
      return path;
    }
    return null;
  }
  
  void dispose() {
    _cameraController?.dispose();
    _audioRecorder.dispose();
  }

  Future<bool> syncFile(String path) async {
    return await _cloudStorage.uploadEvidence(File(path), 'user_id_placeholder');
  }
}
