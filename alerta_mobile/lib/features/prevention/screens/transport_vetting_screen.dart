import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:alerta_mobile/core/services/prembly_service.dart';

class TransportVettingScreen extends StatefulWidget {
  const TransportVettingScreen({super.key});

  @override
  State<TransportVettingScreen> createState() => _TransportVettingScreenState();
}

class _TransportVettingScreenState extends State<TransportVettingScreen> {
  final _plateController = TextEditingController();
  bool _isChecking = false;
  final _premblyService = PremblyService();
  Map<String, dynamic>? _vehicleData;

  // Mock Database of Reports
  final List<VehicleReport> _mockReports = [
    VehicleReport(
      plateNumber: 'KJA-666-XD',
      type: ReportType.danger,
      comment: 'Driver tried to lock the doors! One chance!',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      reporter: 'Anonymous',
      vehicleType: 'Car',
      route: 'Ikeja to Yaba',
    ),
    VehicleReport(
      plateNumber: 'LND-842-AA',
      type: ReportType.safe,
      comment: 'Very polite driver, AC was working.',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      reporter: 'Sarah J.',
      vehicleType: 'Uber/Bolt',
    ),
    VehicleReport(
      plateNumber: 'EKY-192-CC',
      type: ReportType.safe,
      comment: 'Safe trip, drove carefully.',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      reporter: 'Mike T.',
      vehicleType: 'Bus',
      route: 'Lekki to Ajah',
    ),
  ];

  void _checkVehicle() async {
    if (_plateController.text.isEmpty) return;
    
    setState(() {
       _isChecking = true;
       _vehicleData = null;
    });

    try {
      // Call Prembly API
      final data = await _premblyService.verifyVehicle(_plateController.text);
      
      if (mounted) {
        setState(() {
          _isChecking = false;
          _vehicleData = data;
        });
        _showResult(_plateController.text);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
        // For demo purposes, if API fails (e.g. no key), we might still show the mock result but warn
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Verification Error: $e'),
          backgroundColor: AppTheme.primaryRed,
        ));
        // Fallback to show mock reports even if API fails? 
        // User probably wants to see the reports regardless.
        _showResult(_plateController.text);
      }
    }
  }

  void _showResult(String plate) {
    // Filter reports for this vehicle
    final reports = _mockReports.where((r) => r.plateNumber == plate).toList();
    final isDangerous = reports.any((r) => r.type == ReportType.danger);
    
    final color = isDangerous ? AppTheme.primaryRed : (reports.isEmpty ? Colors.grey : AppTheme.successGreen);
    final icon = isDangerous ? Icons.warning_rounded : (reports.isEmpty ? Icons.help_outline_rounded : Icons.verified_user_rounded);
    
    String mainText;
    if (isDangerous) {
      mainText = 'WARNING: FLAGGED UNSAFE';
    } else if (reports.isNotEmpty) {
      mainText = 'Community Verified: SAFE';
    } else {
      mainText = 'No Reports Found';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: color).animate().scale().then().shake(hz: isDangerous ? 4 : 0),
            const SizedBox(height: 16),
            Text(
              isDangerous ? 'DO NOT BOARD' : (reports.isEmpty ? 'PROCEED WITH CAUTION' : 'SAFE TO BOARD'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plate: ${plate.toUpperCase()}',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              mainText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
            
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            const Divider(color: Colors.white10),
            
            // Prembly Verified Data
            if (_vehicleData != null) ...[
               Align(
                 alignment: Alignment.centerLeft,
                 child: Text('OFFICIAL REGISTRATION DETAILS', 
                   style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
               ),
               const SizedBox(height: 12),
               _buildDetailRow('Owner', _vehicleData!['vehicle_owner'] ?? 'N/A'),
               _buildDetailRow('Model', _vehicleData!['vehicle_name'] ?? 'N/A'),
               _buildDetailRow('Color', _vehicleData!['vehicle_color'] ?? 'N/A'),
               _buildDetailRow('Chassis', _vehicleData!['chassis_number'] ?? 'N/A'),
               const SizedBox(height: 24),
               const Divider(color: Colors.white10),
            ],

            const SizedBox(height: 8),
            
            // Community Reports Section
            if (reports.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('COMMUNITY REPORTS (${reports.length})', 
                  style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ...reports.map((report) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: report.type == ReportType.danger ? AppTheme.primaryRed.withOpacity(0.3) : Colors.transparent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          report.type == ReportType.danger ? Icons.warning : Icons.thumb_up,
                          size: 14,
                          color: report.type == ReportType.danger ? AppTheme.primaryRed : AppTheme.successGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(report.reporter, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('2 days ago', style: const TextStyle(color: Colors.white24, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(report.comment, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (report.vehicleType != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                            child: Text(report.vehicleType!, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                          ),
                        const SizedBox(width: 8),
                        if (report.route != null && report.route!.isNotEmpty)
                           Text('Route: ${report.route}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              )).toList(),
            ] else 
              const Text('No community reports yet. Be the first to verify.', style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic)),

            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showReportDialog(plate);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Add Report'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: isDangerous
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Trigger SOS
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                      icon: const Icon(Icons.sos, size: 18),
                      label: const Text('SOS'),
                    )
                  : ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                      child: const Text('Done'),
                    ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(String plate) {
    String selectedVehicle = 'Car';
    final routeController = TextEditingController();

    showDialog(
      context: context, 
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardSurface,
          title: Text('Report $plate', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Help the community. Was this driver safe?', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: selectedVehicle,
                dropdownColor: AppTheme.cardSurface,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue)),
                ),
                items: ['Car', 'Bus', 'Uber/Bolt', 'Keke/Bike'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setDialogState(() => selectedVehicle = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: routeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Route (Optional)',
                  hintText: 'e.g. Ikeja to VI',
                  labelStyle: TextStyle(color: Colors.white54),
                  hintStyle: TextStyle(color: Colors.white24),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue)),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildReportTypeBtn('Safe', Icons.thumb_up, AppTheme.successGreen, () {
                    _addReport(plate, ReportType.safe, vehicle: selectedVehicle, route: routeController.text);
                    Navigator.pop(context);
                  }),
                  _buildReportTypeBtn('Unsafe', Icons.warning, AppTheme.primaryRed, () {
                     _addReport(plate, ReportType.danger, vehicle: selectedVehicle, route: routeController.text);
                     Navigator.pop(context);
                  }),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  Widget _buildReportTypeBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _addReport(String plate, ReportType type, {String? vehicle, String? route}) {
    setState(() {
      _mockReports.insert(0, VehicleReport(
        plateNumber: plate,
        type: type,
        comment: type == ReportType.safe ? 'User reported safe ride.' : 'User flagged as unsafe!',
        timestamp: DateTime.now(),
        reporter: 'You',
        vehicleType: vehicle,
        route: route,
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you for keeping us safe.')));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Vetting'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                   const Icon(Icons.groups, color: AppTheme.primaryBlue), // Changed icon to groups to signify community
                   const SizedBox(width: 16),
                   const Expanded(
                     child: Text(
                       'Community Powered. Verify every Bolt, Uber, or Bus against user reports before you enter.',
                       style: TextStyle(color: Colors.white70),
                     ),
                   )
                ],
              ),
            ),
             const SizedBox(height: 48),
             
             Text(
               'ENTER PLATE NUMBER',
               style: Theme.of(context).textTheme.labelLarge?.copyWith(
                 color: Colors.white54,
                 letterSpacing: 1.5,
               ),
             ),
             const SizedBox(height: 16),
             TextField(
               controller: _plateController,
               textCapitalization: TextCapitalization.characters,
               textAlign: TextAlign.center,
               style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
               decoration: InputDecoration(
                 hintText: 'ABC-123DE',
                 hintStyle: const TextStyle(color: Colors.white12),
                 filled: true,
                 fillColor: Colors.black,
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(12),
                   borderSide: const BorderSide(color: Colors.white24),
                 ),
               ),
             ),
             
             const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isChecking ? null : _checkVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: _isChecking 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('VERIFY VEHICLE'),
              ),
              
              const SizedBox(height: 48),
              
              Text(
                'YOUR RECENT CHECKS',
                 style: Theme.of(context).textTheme.labelLarge?.copyWith(
                   color: Colors.white54,
                   letterSpacing: 1.5,
                 ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView(
                  children: [
                    _buildHistoryItem('KJA-666-XD', false, 'Just now', 'Flagged Unsafe'), // Dangerous (Mock)
                    _buildHistoryItem('LND-842-AA', true, 'Yesterday', 'Verified Safe'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String plate, bool safe, String time, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: safe ? Colors.white10 : AppTheme.primaryRed.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: Icon(
          safe ? Icons.check_circle : Icons.warning,
          color: safe ? AppTheme.successGreen : AppTheme.primaryRed,
        ),
        title: Text(plate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('$status • $time', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        onTap: () => _showResult(plate),
      ),
    );
  }
}

enum ReportType { safe, danger }

class VehicleReport {
  final String plateNumber;
  final ReportType type;
  final String comment;
  final DateTime timestamp;
  final String reporter;
  final String? vehicleType;
  final String? route;

  VehicleReport({
    required this.plateNumber,
    required this.type,
    required this.comment,
    required this.timestamp,
    required this.reporter,
    this.vehicleType,
    this.route,
  });
}
