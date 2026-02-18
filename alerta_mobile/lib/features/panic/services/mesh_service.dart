import 'dart:async';

class MeshService {
  bool _isScanning = false;
  final List<String> _connectedPeers = [];

  // Simulate scanning for nearby Alerta users
  Stream<List<String>> scanForPeers() async* {
    _isScanning = true;
    while (_isScanning) {
      await Future.delayed(const Duration(seconds: 3));
      // Mock: Found a peer every few seconds
      _connectedPeers.add("Device_${DateTime.now().second}");
      yield _connectedPeers;
    }
  }

  Future<void> broadcastSOS(String encryptedPayload) async {
    print("MESH: Broadcasting SOS to ${_connectedPeers.length} nearby peers...");
    // In reality: Write characteristic to BLE peers
    await Future.delayed(const Duration(seconds: 1));
    print("MESH: SOS relayed via 'Device_X' -> Internet");
  }

  void stopScan() {
    _isScanning = false;
  }
}
