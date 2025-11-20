import 'package:monitorist/src/rust/api/nightlight.dart' as nightlight_api;

class NightlightService {
  (double?, bool) loadSettings() {
    return nightlight_api.loadSettings();
  }

  void setStrength(int strength) {
    nightlight_api.setWarmth(warm: strength.toDouble() / 100.0);
  }

  void setActive(bool isActive) {
    nightlight_api.setActive(isActive: isActive);
  }
}
