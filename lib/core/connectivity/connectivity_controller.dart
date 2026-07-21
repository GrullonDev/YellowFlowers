import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// App-wide online/offline signal. Proactively tells the user when
/// they've lost connectivity instead of only reacting after a screen
/// tries (and fails) to load something.
class ConnectivityController extends ChangeNotifier {
  ConnectivityController() {
    _sub = Connectivity().onConnectivityChanged.listen(_handle);
    // Seed the initial state; defaults to online until the first check
    // resolves so we never show a false "offline" flash on cold start.
    Connectivity().checkConnectivity().then(_handle).catchError((_) {});
  }

  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void _handle(List<ConnectivityResult> results) {
    final online = results.isEmpty ||
        results.any((r) => r != ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
