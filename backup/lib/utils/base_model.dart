import 'package:flutter/material.dart';

class BaseModel extends ChangeNotifier {
  bool isMounted = true;

  bool _busy = false;
  bool get busy => _busy;

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  @visibleForTesting
  void updateBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    isMounted = false;

    super.dispose();
  }

  bool get isActive => isMounted;

  @override
  void notifyListeners() {
    if (isMounted) {
      super.notifyListeners();
    }
  }
}
