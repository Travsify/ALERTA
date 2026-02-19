import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _connectivity.onConnectivityChanged.listen(_updateStatus);
    checkConnectivity();
  }

  final Connectivity _connectivity = Connectivity();
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  Future<void> checkConnectivity() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // If results contains anything other than 'none', we are online
    final bool currentlyOffline = results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    
    if (_isOffline != currentlyOffline) {
      _isOffline = currentlyOffline;
      notifyListeners();
      debugPrint("📡 CONNECTIVITY: Device is ${_isOffline ? 'OFFLINE' : 'ONLINE'}");
    }
  }
}
