import 'package:flutter/foundation.dart';
import 'package:monitorist/services/monitors_service.dart';
import 'package:monitorist/services/nightlight_service.dart';
import 'package:monitorist/services/profiles_service.dart';
import 'package:monitorist/src/rust/api/monitors.dart';
import 'package:monitorist/viewmodels/profiles_viewmodel.dart';

class EditProfileViewmodel extends ChangeNotifier {
  final bool _isNew;
  final String _oldName;
  String _name;
  bool _preview;
  late final NightlightCardViewmodel nightlightCardViewmodel;
  final List<MonitorCardViewmodel> monitorCardViewmodels = [];
  final NightlightService _nightlightService;
  final MonitorsService _monitorsService;
  final ProfilesViewmodel _profilesViewmodel;

  EditProfileViewmodel.newProfile({
    required NightlightService nightlightService,
    required MonitorsService monitorsService,
    required ProfilesViewmodel profilesViewmodel,
  }) : _isNew = true,
       _oldName = "New Profile",
       _name = "New Profile",
       _preview = true,
       _nightlightService = nightlightService,
       _monitorsService = monitorsService,
       _profilesViewmodel = profilesViewmodel {
    final (strength, isEnabled) = _nightlightService.loadSettings();
    nightlightCardViewmodel = NightlightCardViewmodel(
      isEnabled: isEnabled,
      baselineIsEnabled: isEnabled,
      strength: strength,
      baselineStrength: strength,
      isIncluded: true,
      parent: this,
      nightlightService: _nightlightService,
    );
    loadMonitors();
  }

  Future<void> loadMonitors() async {
    final results = await _monitorsService.getMonitors();
    for (final result in results) {
      if (result.success != null) {
        final monitor = result.success!;
        final brightness = await monitor.getBrightness().then(
          (value) => value.toDouble(),
        );
        monitorCardViewmodels.add(
          MonitorCardViewmodel(
            id: await monitor.deviceName(),
            name: await monitor.displayName(),
            brightness: brightness,
            baselineBrightness: brightness,
            isIncluded: true,
            exists: true,
            parent: this,
            monitor: monitor,
          ),
        );
      }
    }
    notifyListeners();
  }

  bool get preview => _preview;
  String get name => _name;
  bool get isNew => _isNew;

  void setPreview(bool preview) {
    _preview = preview;
    nightlightCardViewmodel.onPreviewChange();
    for (var monitorCard in monitorCardViewmodels) {
      monitorCard.onPreviewChange();
    }
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void restoreBaseline() {
    nightlightCardViewmodel.restoreBaseline();
    for (var monitorCard in monitorCardViewmodels) {
      monitorCard.restoreBaseline();
    }
  }

  void saveProfile() {
    final nightlightProfile = nightlightCardViewmodel.isIncluded
        ? NightlightProfile(
            isEnabled: nightlightCardViewmodel.isEnabled,
            strength: nightlightCardViewmodel.strength,
          )
        : null;
    final monitorsProfile = monitorCardViewmodels
        .where((vm) => vm.isIncluded)
        .map((vm) => MonitorProfile(id: vm.id, brightness: vm.brightness))
        .toList();
    final profile = Profile(
      name: _name,
      nightlightProfile: nightlightProfile,
      monitorsProfile: monitorsProfile,
    );
    if (_isNew) {
      _profilesViewmodel.addProfile(profile);
    } else {
      _profilesViewmodel.updateProfile(name: _oldName, newProfile: profile);
    }
    restoreBaseline();
  }
}

class NightlightCardViewmodel extends ChangeNotifier {
  bool _isEnabled;
  final bool _baselineIsEnabled;
  double? _strength;
  final double? _baselineStrength;
  bool _isIncluded;
  final NightlightService _nightlightService;
  final EditProfileViewmodel _parent;

  NightlightCardViewmodel({
    required bool isEnabled,
    required bool baselineIsEnabled,
    required double? strength,
    required double? baselineStrength,
    required bool isIncluded,
    required EditProfileViewmodel parent,
    required NightlightService nightlightService,
  }) : _isEnabled = isEnabled,
       _baselineIsEnabled = baselineIsEnabled,
       _strength = strength,
       _baselineStrength = baselineStrength,
       _isIncluded = isIncluded,
       _parent = parent,
       _nightlightService = nightlightService;

  bool get isEnabled => _isEnabled;
  double? get strength => _strength;
  bool get isIncluded => _isIncluded;

  void setIncluded(bool included) {
    _isIncluded = included;
    notifyListeners();
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (_parent.preview) {
      _nightlightService.setActive(enabled);
    }
    notifyListeners();
  }

  void setStrength(double strength) {
    _strength = strength;
    if (_parent.preview) {
      _nightlightService.setStrength(strength);
    }
    notifyListeners();
  }

  void onPreviewChange() {
    if (_parent.preview) {
      _nightlightService.setActive(_isEnabled);
      if (_strength != null) {
        _nightlightService.setStrength(_strength!);
      }
    } else {
      restoreBaseline();
    }
  }

  void restoreBaseline() {
    _nightlightService.setActive(_baselineIsEnabled);
    if (_baselineStrength != null) {
      _nightlightService.setStrength(_baselineStrength);
    }
  }
}

class MonitorCardViewmodel extends ChangeNotifier {
  final String id;
  final String name;
  final bool exists;
  double _brightness;
  final double _baselineBrightness;
  bool _isIncluded;
  final EditProfileViewmodel _parent;
  final Monitor? _monitor;

  MonitorCardViewmodel({
    required this.id,
    required this.name,
    required double brightness,
    required double baselineBrightness,
    required bool isIncluded,
    required this.exists,
    required EditProfileViewmodel parent,
    Monitor? monitor,
  }) : _brightness = brightness,
       _baselineBrightness = baselineBrightness,
       _isIncluded = isIncluded,
       _parent = parent,
       _monitor = monitor;

  double get brightness => _brightness;
  bool get isIncluded => _isIncluded;

  void setIncluded(bool included) {
    _isIncluded = included;
    notifyListeners();
  }

  void setBrightness(double brightness) {
    _brightness = brightness;
    if (_parent.preview) {
      _monitor?.setBrightness(value: brightness.toInt());
    }
    notifyListeners();
  }

  void onPreviewChange() {
    if (_parent.preview) {
      _monitor?.setBrightness(value: _brightness.toInt());
    } else {
      restoreBaseline();
    }
  }

  void restoreBaseline() {
    _monitor?.setBrightness(value: _baselineBrightness.toInt());
  }
}
