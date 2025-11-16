import 'package:monitorist/src/rust/api/nightlight.dart' as nightlight_api;

class NightlightService {
  (double?, bool) loadSettings() {
    return nightlight_api.loadSettings();
  }

  void setStrength(double strength) {
    nightlight_api.setWarmth(strength: strength);
  }

  void setActive(bool isActive) {
    nightlight_api.setActive(isActive: isActive);
  }
}
