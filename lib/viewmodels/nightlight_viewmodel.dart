import 'package:flutter/foundation.dart';
import 'package:monitorist/services/nightlight_service.dart';

class NightlightViewModel extends ChangeNotifier {
  final NightlightService _nightlightService;
  double? _strength;
  bool _isEnabled = false;

  NightlightViewModel({required NightlightService nightlightService}) : _nightlightService = nightlightService {
    _loadSettings();
  }

  double? get strength => _strength;
  bool get isEnabled => _isEnabled;

  void _loadSettings() {
    final (strength, isEnabled) = _nightlightService.loadSettings();
    _strength = strength;
    _isEnabled = isEnabled;
    notifyListeners();
  }

  Future<void> setStrength(double strength) async {
    _strength = strength;
    notifyListeners();
    _nightlightService.setStrength(strength);
  }

  void setActive(bool isActive) {
    _nightlightService.setActive(isActive);
    _isEnabled = isActive;
    notifyListeners();
  }
}
