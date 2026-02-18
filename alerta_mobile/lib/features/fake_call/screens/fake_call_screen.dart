import 'dart:async';
import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FakeCallScreen extends StatefulWidget {
  final String callerName;
  final String callerNumber;
  final int delaySeconds;

  const FakeCallScreen({
    super.key,
    this.callerName = 'Mom',
    this.callerNumber = '+234 801 234 5678',
    this.delaySeconds = 5,
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _isRinging = false;
  bool _isAnswered = false;
  Timer? _ringTimer;
  Timer? _callTimer;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() {
    Timer(Duration(seconds: widget.delaySeconds), () {
      if (mounted) {
        setState(() => _isRinging = true);
        _startRinging();
      }
    });
  }

  void _startRinging() {
    // Vibrate pattern
    HapticFeedback.vibrate();
    _ringTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_isRinging && mounted) {
        HapticFeedback.vibrate();
      }
    });
  }

  void _answerCall() {
    setState(() {
      _isRinging = false;
      _isAnswered = true;
    });
    _ringTimer?.cancel();
    
    // Start call duration timer
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _callDuration++);
    });
  }

  void _endCall() {
    _ringTimer?.cancel();
    _callTimer?.cancel();
    Navigator.of(context).pop();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _ringTimer?.cancel();
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: !_isRinging && !_isAnswered
            ? _buildWaitingUI()
            : _isRinging
                ? _buildIncomingCallUI()
                : _buildOngoingCallUI(),
      ),
    );
  }

  Widget _buildWaitingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryRed),
          const SizedBox(height: 24),
          Text(
            'Call coming in ${widget.delaySeconds} seconds...',
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingCallUI() {
    return Column(
      children: [
        const Spacer(),
        // Caller Avatar
        CircleAvatar(
          radius: 60,
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            widget.callerName[0].toUpperCase(),
            style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ).animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)).then().scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1)),
        const SizedBox(height: 24),
        Text(
          widget.callerName,
          style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.callerNumber,
          style: const TextStyle(fontSize: 18, color: Colors.white54),
        ),
        const SizedBox(height: 16),
        const Text(
          'Incoming Call...',
          style: TextStyle(color: Colors.green, fontSize: 16),
        ).animate(onPlay: (c) => c.repeat()).fade(duration: 1.seconds).then().fade(begin: 1, end: 0.3),
        const Spacer(),
        
        // Answer/Decline Buttons
        Padding(
          padding: const EdgeInsets.all(48.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Decline
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                ),
              ),
              // Answer
              GestureDetector(
                onTap: _answerCall,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call, color: Colors.white, size: 32),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOngoingCallUI() {
    return Column(
      children: [
        const Spacer(),
        CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            widget.callerName[0].toUpperCase(),
            style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.callerName,
          style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _formatDuration(_callDuration),
          style: const TextStyle(fontSize: 18, color: Colors.green),
        ),
        const Spacer(),
        
        // Call Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCallControl(Icons.mic_off, 'Mute'),
            _buildCallControl(Icons.dialpad, 'Keypad'),
            _buildCallControl(Icons.volume_up, 'Speaker'),
          ],
        ),
        const SizedBox(height: 48),
        
        // End Call
        GestureDetector(
          onTap: _endCall,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call_end, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildCallControl(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
