import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/live_location/services/live_location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareTripScreen extends StatefulWidget {
  const ShareTripScreen({super.key});

  @override
  State<ShareTripScreen> createState() => _ShareTripScreenState();
}

class _ShareTripScreenState extends State<ShareTripScreen> {
  final LiveLocationService _service = LiveLocationService();
  double _durationSlider = 30;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share My Trip'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _service.isSharing ? _buildSharingView() : _buildSetupView(),
      ),
    );
  }

  Widget _buildSetupView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(FontAwesomeIcons.locationArrow, size: 64, color: AppTheme.primaryBlue),
        const SizedBox(height: 24),
        Text(
          'Share Your Live Location',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Your trusted contacts will receive your location updates via SMS until you stop sharing or the timer ends.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 48),
        
        Text(
          '${_durationSlider.round()} minutes',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
          textAlign: TextAlign.center,
        ),
        Slider(
          value: _durationSlider,
          min: 10,
          max: 120,
          divisions: 11,
          activeColor: AppTheme.primaryBlue,
          onChanged: (v) => setState(() => _durationSlider = v),
        ),
        const Text(
          'How long should we share your location?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38),
        ),
        
        const Spacer(),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white38),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Updates will be sent every 5 minutes to contacts with location sharing enabled.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        ElevatedButton.icon(
          onPressed: () {
            _service.startSharing(durationMinutes: _durationSlider.round());
          },
          icon: const Icon(Icons.share_location),
          label: const Text('START SHARING'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildSharingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.successGreen, width: 4),
            boxShadow: [
              BoxShadow(color: AppTheme.successGreen.withOpacity(0.3), blurRadius: 30, spreadRadius: 10),
            ],
          ),
          child: const Icon(Icons.share_location, size: 64, color: AppTheme.successGreen),
        ).animate(onPlay: (c) => c.repeat()).fade(duration: 2.seconds).then().fade(begin: 1, end: 0.5),
        const SizedBox(height: 32),
        
        const Text(
          'SHARING LIVE LOCATION',
          style: TextStyle(
            color: AppTheme.successGreen,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_service.remainingMinutes} minutes remaining',
          style: const TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 16),
        
        if (_service.lastPosition != null)
          Text(
            'Last Update: ${_service.lastPosition!.latitude.toStringAsFixed(4)}, ${_service.lastPosition!.longitude.toStringAsFixed(4)}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        
        const SizedBox(height: 48),
        
        OutlinedButton.icon(
          onPressed: () {
            _service.stopSharing();
          },
          icon: const Icon(Icons.stop),
          label: const Text('STOP SHARING'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }
}
