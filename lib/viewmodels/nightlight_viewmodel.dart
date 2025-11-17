import 'package:flutter/foundation.dart';
import 'package:monitorist/services/nightlight_service.dart';

class NightlightPanelViewmodel extends ChangeNotifier {
  final NightlightService _nightlightService;
  double? _strength;
  bool _isEnabled = false;

  NightlightPanelViewmodel({required NightlightService nightlightService}) : _nightlightService = nightlightService {
    loadSettings();
  }

  double? get strength => _strength;
  bool get isEnabled => _isEnabled;

  void loadSettings() {
    final (strength, isEnabled) = _nightlightService.loadSettings();
    _strength = strength;
    _isEnabled = isEnabled;
    notifyListeners();
  }

  void setStrength(double strength) {
    _nightlightService.setStrength(strength);
    _strength = strength;
    notifyListeners();
  }

  void setActive(bool isActive) {
    _nightlightService.setActive(isActive);
    _isEnabled = isActive;
    notifyListeners();
  }
}
