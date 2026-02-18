import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CrisisLogScreen extends StatefulWidget {
  const CrisisLogScreen({super.key});

  @override
  State<CrisisLogScreen> createState() => _CrisisLogScreenState();
}

class _CrisisLogScreenState extends State<CrisisLogScreen> {
  final List<Map<String, String>> _logs = [
    {
      'time': '10:30 AM',
      'type': 'INCIDENT',
      'note': 'Subject missed 10AM check-in. Dead Man Switch triggered.',
    },
    {
      'time': '10:45 AM',
      'type': 'ACTION',
      'note': 'Tried calling subject. Phone unreachable.',
    },
  ];

  final _noteController = TextEditingController();

  void _addLog() {
    if (_noteController.text.isEmpty) return;
    setState(() {
      _logs.insert(0, {
        'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'type': 'FAMILY',
        'note': _noteController.text,
      });
      _noteController.clear();
    });
    Navigator.pop(context);
  }

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Add Log Entry', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _noteController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g., "Received call from unknown number..."',
            hintStyle: TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addLog,
            child: const Text('Save Entry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crisis Log'), // Explicitly named for the situation
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library, color: Colors.white),
            onPressed: () {
               // Placeholder for Vault
               showDialog(context: context, builder: (_) => AlertDialog(
                 backgroundColor: AppTheme.cardSurface,
                 title: const Text('Evidence Vault', style: TextStyle(color: Colors.white)),
                 content: const Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     ListTile(leading: Icon(Icons.videocam, color: Colors.red), title: Text('Incident_001.mp4', style: TextStyle(color: Colors.white)), subtitle: Text('10:30 AM - Cloud Sync', style: TextStyle(color: Colors.white54))),
                     ListTile(leading: Icon(Icons.mic, color: Colors.orange), title: Text('Audio_Log_002.aac', style: TextStyle(color: Colors.white)), subtitle: Text('10:32 AM - Cloud Sync', style: TextStyle(color: Colors.white54))),
                   ],
                 ),
                 actions: [TextButton(child: const Text('Close'), onPressed: () => Navigator.pop(context))],
               ));
            },
            tooltip: 'View Evidence',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppTheme.primaryRed),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting securely to authorities...')));
            },
            tooltip: 'Export for Police',
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryRed.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.primaryRed, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This log is encrypted. Use it to record ransom demands, police interactions, and proof-of-life.',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isIncident = log['type'] == 'INCIDENT';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(log['time']!, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Icon(
                            isIncident ? Icons.warning : Icons.circle, 
                            size: 12, 
                            color: isIncident ? AppTheme.primaryRed : Colors.white24
                          ),
                          Container(width: 2, height: 40, color: Colors.white10),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: isIncident ? Border.all(color: AppTheme.primaryRed.withOpacity(0.5)) : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log['type']!, style: TextStyle(color: isIncident ? AppTheme.primaryRed : AppTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(log['note']!, style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.edit_note),
      ),
    );
  }
}
