import 'dart:io';

import 'package:monitorist/src/rust/api/nightlight.dart' as nightlight_api;

class NightlightService {
  (double?, bool) loadSettings() {
    if (!Platform.isWindows) {
      return (null, false);
    }
    return nightlight_api.loadSettings();
  }

  void setStrength(int strength) {
    if (!Platform.isWindows) {
      return;
    }
    nightlight_api.setWarmth(warm: strength.toDouble() / 100.0);
  }

  void setActive(bool isActive) {
    if (!Platform.isWindows) {
      return;
    }
    nightlight_api.setActive(isActive: isActive);
  }
}
