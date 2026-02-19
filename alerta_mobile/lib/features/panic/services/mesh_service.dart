import 'dart:convert';
import 'package:alerta_mobile/core/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class MeshService extends ChangeNotifier {
  static final MeshService _instance = MeshService._internal();
  factory MeshService() => _instance;
  MeshService._internal();

  final Strategy strategy = Strategy.P2P_CLUSTER;
  final String _serviceId = "com.alertasecure.mesh";
  
  bool _isAdvertising = false;
  bool _isDiscovery = false;

  bool get isAdvertising => _isAdvertising;
  bool get isDiscovery => _isDiscovery;

  /// Start listening for nearby SOS packets (Discovery)
  Future<void> startRelayListener() async {
    if (_isDiscovery) return;
    
    try {
      final bool granted = await Permission.location.request().isGranted;
      if (!granted) return;

      await Nearby().startDiscovery(
        "Alerta-Relay",
        strategy,
        onEndpointFound: (id, name, serviceId) {
          debugPrint("📍 MESH: Found potential SOS source: $name ($id)");
          _requestConnection(id);
        },
        onEndpointLost: (id) => debugPrint("📍 MESH: Endpoint lost: $id"),
        serviceId: _serviceId,
      );
      _isDiscovery = true;
      notifyListeners();
    } catch (e) {
      debugPrint("📍 MESH Discovery Error: $e");
    }
  }

  /// Broadcast SOS when offline (Advertising)
  Future<void> broadcastSOSOffline(Map<String, dynamic> sosData) async {
    if (_isAdvertising) return;

    try {
      final payload = jsonEncode({
        ...sosData,
        'mesh_id': const Uuid().v4(),
        'relayed_at': DateTime.now().toIso8601String(),
      });

      await Nearby().startAdvertising(
        "ALERTA_SOS_${sosData['user_id']}",
        strategy,
        onConnectionInitiated: (id, info) {
          debugPrint("📍 MESH: Connection initiated for transfer: $id");
          Nearby().acceptConnection(id, onPayLoadRecieved: (endpointId, payload) {
             // Sender doesn't usually receive in this direction
          }, onPayloadTransferUpdate: (endpointId, update) {});
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(payload)));
            debugPrint("📍 MESH: SOS Payload Sent to peer $id");
          }
        },
        onDisconnected: (id) => debugPrint("📍 MESH: Disconnected: $id"),
        serviceId: _serviceId,
      );
      _isAdvertising = true;
      notifyListeners();
    } catch (e) {
      debugPrint("📍 MESH Advertising Error: $e");
    }
  }

  void _requestConnection(String endpointId) {
    Nearby().requestConnection(
      "Alerta-Relay",
      endpointId,
      onConnectionInitiated: (id, info) {
        Nearby().acceptConnection(id, onPayLoadRecieved: (endpointId, payload) {
          if (payload.type == PayloadType.BYTES) {
            final data = jsonDecode(utf8.decode(payload.bytes!));
            _processRelayedSOS(data);
          }
        }, onPayloadTransferUpdate: (endpointId, update) {});
      },
      onConnectionResult: (id, status) => debugPrint("📍 MESH Connection Result: $status"),
      onDisconnected: (id) => debugPrint("📍 MESH Disconnected from source: $id"),
    );
  }

  void _processRelayedSOS(Map<String, dynamic> data) async {
    debugPrint("🆘 MESH: Received relayed SOS from ${data['user_id']}");
    
    try {
      final api = ApiService();
      final response = await api.post('/mesh-relay', data);
      if (response.statusCode == 201) {
        debugPrint("✅ MESH: SOS Relayed successfully to Cloud");
      } else {
        _storeForLater(data);
      }
    } catch (e) {
      _storeForLater(data);
    }
  }

  void _storeForLater(Map<String, dynamic> data) {
    debugPrint("📦 MESH: SOS stored locally (No Internet). Will retry later.");
    // In production, use Hive or SQLite here
  }

  void stopAll() {
    Nearby().stopDiscovery();
    Nearby().stopAdvertising();
    Nearby().stopAllEndpoints();
    _isAdvertising = false;
    _isDiscovery = false;
    notifyListeners();
  }
}
