import 'dart:async';
import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/threat_radar/services/threat_radar_service.dart';
import 'package:alerta_mobile/features/threat_radar/services/threat_report_store.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ThreatRadarScreen extends StatefulWidget {
  const ThreatRadarScreen({super.key});

  @override
  State<ThreatRadarScreen> createState() => _ThreatRadarScreenState();
}

class _ThreatRadarScreenState extends State<ThreatRadarScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final ThreatReportStore _store = ThreatReportStore();
  final ThreatRadarService _radarService = ThreatRadarService();
  
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  Position? _currentPosition;

  static const CameraPosition _kLagos = CameraPosition(
    target: LatLng(6.5244, 3.3792),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _radarService.startMonitoring();
    _loadThreats();
    _getCurrentLocation();
    
    // Listen for updates
    _store.addListener(_refreshMap);
  }

  @override
  void dispose() {
    _radarService.stopMonitoring();
    _store.removeListener(_refreshMap);
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
      
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ));
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void _loadThreats() {
    final threats = _store.getAllThreatZones();
    _updateMapElements(threats);
  }

  void _refreshMap() {
    if (mounted) {
      _loadThreats();
    }
  }

  void _updateMapElements(List<ThreatZone> threats) {
    Set<Marker> newMarkers = {};
    Set<Circle> newCircles = {};

    for (var threat in threats) {
      // Create Marker
      newMarkers.add(Marker(
        markerId: MarkerId(threat.id),
        position: LatLng(threat.latitude, threat.longitude),
        infoWindow: InfoWindow(
          title: threat.name,
          snippet: '${threat.type.toUpperCase()} - ${threat.radiusMeters.round()}m radius',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          threat.type == 'danger' ? BitmapDescriptor.hueRed : BitmapDescriptor.hueOrange,
        ),
      ));

      // Create Danger Zone Circle
      newCircles.add(Circle(
        circleId: CircleId(threat.id),
        center: LatLng(threat.latitude, threat.longitude),
        radius: threat.radiusMeters,
        fillColor: (threat.type == 'danger' ? Colors.red : Colors.orange).withOpacity(0.3),
        strokeColor: threat.type == 'danger' ? Colors.red : Colors.orange,
        strokeWidth: 2,
      ));
    }

    setState(() {
      _markers = newMarkers;
      _circles = newCircles;
    });
  }

  void _showReportDialog() {
    final nameController = TextEditingController();
    String selectedType = 'danger';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Report Threat', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Robbery in progress',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              dropdownColor: AppTheme.cardSurface,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ['danger', 'checkpoint', 'accident', 'riot']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase(), style: const TextStyle(color: Colors.white))))
                  .toList(),
              onChanged: (v) => selectedType = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && _currentPosition != null) {
                _store.addReport(
                  name: nameController.text,
                  latitude: _currentPosition!.latitude,
                  longitude: _currentPosition!.longitude,
                  type: selectedType,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted! Thank you for keeping the community safe.')),
                );
              }
            },
            child: const Text('REPORT'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal, // Use normal for better visibility of roads
            initialCameraPosition: _kLagos,
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              // Set dark style for map if desired
              // controller.setMapStyle(_mapStyle); 
            },
          ),
          
          // Custom Back Button
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Title Card
          Positioned(
            top: 50,
            left: 70,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.primaryRed.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.radar, color: AppTheme.primaryRed, size: 16),
                  SizedBox(width: 12),
                  Text(
                    'Threat Radar: ACTIVE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReportDialog,
        backgroundColor: AppTheme.primaryRed,
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('REPORT INCIDENT'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
