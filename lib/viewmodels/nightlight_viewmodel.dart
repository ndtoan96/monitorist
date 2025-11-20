import 'package:flutter/foundation.dart';
import 'package:monitorist/services/nightlight_service.dart';

class NightlightViewModel extends ChangeNotifier {
  final NightlightService _nightlightService;
  int? _strength;
  bool _isEnabled = false;

  NightlightViewModel({required NightlightService nightlightService}) : _nightlightService = nightlightService {
    _loadSettings();
  }

  int? get strength => _strength;
  bool get isEnabled => _isEnabled;

  void _loadSettings() {
    final (warmth, isEnabled) = _nightlightService.loadSettings();
    _strength = warmth != null ? (warmth * 100).round() : null;
    _isEnabled = isEnabled;
    notifyListeners();
  }

  Future<void> setStrength(int strength) async {
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
