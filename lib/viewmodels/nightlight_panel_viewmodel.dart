import 'package:flutter/foundation.dart';
import 'package:monitorist/services/nightlight_service.dart';

class NightlightPanelViewmodel extends ChangeNotifier {
  NightlightService nightlightService;
  double? _strength;
  bool _isEnabled = false;

  NightlightPanelViewmodel({required this.nightlightService}) {
    loadSettings();
  }

  double? get strength => _strength;
  bool get isEnabled => _isEnabled;

  void loadSettings() {
    final (strength, isEnabled) = nightlightService.loadSettings();
    _strength = strength;
    _isEnabled = isEnabled;
    notifyListeners();
  }

  void setStrength(double strength) {
    nightlightService.setStrength(strength);
    _strength = strength;
    notifyListeners();
  }

  void setActive(bool isActive) {
    nightlightService.setActive(isActive);
    _isEnabled = isActive;
    notifyListeners();
  }
}
