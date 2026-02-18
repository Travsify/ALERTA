import 'dart:io';
import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:camera/camera.dart';
import 'package:alerta_mobile/features/prevention/services/recorder_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';

class BlackboxScreen extends StatefulWidget {
  const BlackboxScreen({super.key});

  @override
  State<BlackboxScreen> createState() => _BlackboxScreenState();
}

class _BlackboxScreenState extends State<BlackboxScreen> {
  final RecorderService _recorderService = RecorderService();
  bool _isRecording = false;
  bool _videoMode = false;
  List<EvidenceItem> _evidenceList = [];

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadMockData();
  }

  void _initializeService() async {
    await _requestPermissions();
    await _recorderService.initialize();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone, Permission.storage].request();
  }

  void _loadMockData() {
    setState(() {
      _evidenceList = [
        EvidenceItem('VID_20251010_SOS.mp4', '10 Oct, 10:24 PM', Icons.videocam, 'Synced'),
        EvidenceItem('AUD_20251010_SOS.aac', '10 Oct, 10:24 PM', Icons.mic, 'Synced'),
      ];
    });
  }

  void _toggleRecording() async {
    setState(() => _isRecording = !_isRecording);

    if (_isRecording) {
      // Start
      if (_videoMode) {
        final res = await _recorderService.startVideoRecording();
        if (res != null && res.contains('Error')) {
           _isRecording = false; // Revert
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
           return;
        }
      } else {
        await _recorderService.startAudioRecording();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_videoMode ? 'Video Recording Started...' : 'Audio Recording Started...'),
        backgroundColor: AppTheme.primaryRed,
      ));
    } else {
      // Stop
      File? file;
      IconData icon = Icons.mic;
      
      if (_videoMode) {
        file = await _recorderService.stopVideoRecording();
        icon = Icons.videocam;
      } else {
        final path = await _recorderService.stopAudioRecording();
        if (path != null) file = File(path);
      }
      
      if (file != null) {
        final newItem = EvidenceItem(
            '${_videoMode ? "VID" : "AUD"}_${DateTime.now().millisecondsSinceEpoch}.${_videoMode ? "mp4" : "m4a"}',
            'Just Now',
            icon,
            'Syncing...'
        );

        setState(() {
          _evidenceList.insert(0, newItem);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to ${file!.path}. Syncing...')));

        // Trigger Sync
        final success = await _recorderService.syncFile(file.path);
        
        if (mounted) {
           setState(() {
             _evidenceList.remove(newItem);
             _evidenceList.insert(0, EvidenceItem(
               newItem.title,
               newItem.date,
               newItem.icon,
               success ? 'Synced' : 'Sync Failed'
             ));
           });
        }
      }
    }
  }

  @override
  void dispose() {
    _recorderService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blackbox Evidence'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            height: _videoMode ? 300 : null,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _isRecording ? AppTheme.primaryRed : Colors.white10),
            ),
            child: _videoMode && _recorderService.cameraController != null && _recorderService.cameraController!.value.isInitialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                     aspectRatio: _recorderService.cameraController!.value.aspectRatio,
                     child: CameraPreview(_recorderService.cameraController!),
                  ),
                )
              : Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _isRecording ? AppTheme.primaryRed : Colors.redAccent,
                      child: Icon(_videoMode ? Icons.videocam : Icons.mic, color: Colors.white),
                    ).animate(
                      target: _isRecording ? 1 : 0,
                      onPlay: (controller) => controller.repeat(),
                    ).fade(duration: 1.seconds).then().fade(begin: 1.0, end: 0.5),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRecording ? 'RECORDING IN PROGRESS' : 'System Active',
                            style: TextStyle(
                              color: _isRecording ? AppTheme.primaryRed : Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(_videoMode ? 'Video Mode Active' : 'Audio Mode Active', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _videoMode, 
                      onChanged: _isRecording ? null : (v) async {
                        setState(() => _videoMode = v);
                        if (v) await _recorderService.initialize(); // Init camera on switch
                        setState(() {});
                      }, 
                      activeColor: AppTheme.primaryBlue,
                      activeTrackColor: Colors.white10,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white10,
                      thumbIcon: MaterialStateProperty.resolveWith<Icon?>((Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return const Icon(Icons.videocam, color: Colors.black);
                        }
                        return const Icon(Icons.mic, color: Colors.black);
                      }),
                    ),
                  ],
                ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _evidenceList.length,
              itemBuilder: (context, index) {
                final item = _evidenceList[index];
                return _buildEvidenceItem(context, item);
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
              label: Text(_isRecording ? 'STOP RECORDING' : 'START ${_videoMode ? "VIDEO" : "AUDIO"} RECORDING'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.white : AppTheme.primaryRed,
                foregroundColor: _isRecording ? AppTheme.primaryRed : Colors.white,
                padding: const EdgeInsets.all(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceItem(BuildContext context, EvidenceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, color: Colors.white70),
        ),
        title: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(item.date, style: const TextStyle(color: Colors.white38)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_done, color: item.status == 'Synced' ? AppTheme.successGreen : Colors.orange, size: 16),
            const SizedBox(height: 4),
            Text(item.status, style: TextStyle(color: item.status == 'Synced' ? AppTheme.successGreen : Colors.orange, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class EvidenceItem {
  final String title;
  final String date;
  final IconData icon;
  final String status;

  EvidenceItem(this.title, this.date, this.icon, this.status);
}
