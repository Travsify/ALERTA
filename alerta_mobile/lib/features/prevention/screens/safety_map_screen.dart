import 'dart:async';
import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/core/theme/typography.dart';
import 'package:alerta_mobile/features/threat_radar/services/threat_report_store.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SafetyMapScreen extends StatefulWidget {
  const SafetyMapScreen({super.key});

  @override
  State<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends State<SafetyMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final ThreatReportStore _reportStore = ThreatReportStore();

  static const CameraPosition _kLagos = CameraPosition(
    target: LatLng(6.5244, 3.3792), // Default to Lagos
    zoom: 14.4746,
  );

  Set<Marker> _markers = {};
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMarkers();
    _reportStore.addListener(_loadMarkers);
  }

  @override
  void dispose() {
    _reportStore.removeListener(_loadMarkers);
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _loadMarkers() {
    final threats = _reportStore.getAllThreatZones();
    setState(() {
      _markers = threats.map((zone) {
        return Marker(
          markerId: MarkerId(zone.id),
          position: LatLng(zone.latitude, zone.longitude),
          infoWindow: InfoWindow(title: zone.name, snippet: zone.type.toUpperCase()),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            zone.type == 'danger' ? BitmapDescriptor.hueRed :
            zone.type == 'checkpoint' ? BitmapDescriptor.hueBlue :
            BitmapDescriptor.hueOrange, // accident
          ),
        );
      }).toSet();
    });
  }

  void _reportIncident() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report Incident', style: AppTypography.heading2),
            const SizedBox(height: 8),
            Text(
              _currentLocation != null 
                ? 'Location: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}'
                : 'Getting location...',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildReportOption(Icons.local_police, 'Checkpoint', Colors.blue, 'checkpoint'),
                _buildReportOption(Icons.warning, 'Danger', Colors.red, 'danger'),
                _buildReportOption(Icons.car_crash, 'Accident', Colors.orange, 'accident'),
              ],
            ),
            const Spacer(),
            const Text(
              'Your report will be anonymously shared with nearby users to help keep them safe.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(IconData icon, String label, Color color, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _submitReport(type, label);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  void _submitReport(String type, String label) {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get location. Please enable GPS.')),
      );
      return;
    }

    // Add to the shared store
    _reportStore.addReport(
      name: '$label reported by user',
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      type: type,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label reported! Other users will be alerted.'),
        backgroundColor: AppTheme.successGreen,
      ),
    );

    // Add marker immediately
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('new_${DateTime.now().millisecondsSinceEpoch}'),
          position: _currentLocation!,
          infoWindow: InfoWindow(title: '$label (Just Now)', snippet: 'Reported by you'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            type == 'danger' ? BitmapDescriptor.hueRed :
            type == 'checkpoint' ? BitmapDescriptor.hueBlue :
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kLagos,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          
          // Legend
          Positioned(
            top: 60,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.red, 'Danger Zone'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.blue, 'Checkpoint'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.orange, 'Accident'),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 32,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _reportIncident,
              backgroundColor: AppTheme.primaryRed,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('REPORT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
