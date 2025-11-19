import 'package:flutter/foundation.dart';
import 'package:monitorist/models/profile.dart';
import 'package:monitorist/viewmodels/monitors_viewmodel.dart';
import 'package:monitorist/viewmodels/nightlight_viewmodel.dart';
import 'package:monitorist/viewmodels/profiles_viewmodel.dart';

class EditProfileViewModel extends ChangeNotifier {
  final bool _isNew;
  final String _oldName;
  String _name;
  bool _preview;
  late final EditProfileNightlightViewModel editProfileNightlightViewModel;
  final List<EditProfileMonitorViewModel> editProfileMonitorViewModels = [];
  final NightlightViewModel _nightlightViewModel;
  final MonitorsViewModel _monitorsViewModel;
  final ProfilesViewModel _profilesViewmodel;

  EditProfileViewModel.newProfile({
    required NightlightViewModel nightlightViewModel,
    required MonitorsViewModel monitorsViewModel,
    required ProfilesViewModel profilesViewmodel,
  }) : _isNew = true,
       _oldName = "New Profile",
       _name = "New Profile",
       _preview = true,
       _nightlightViewModel = nightlightViewModel,
       _monitorsViewModel = monitorsViewModel,
       _profilesViewmodel = profilesViewmodel {
    editProfileNightlightViewModel = EditProfileNightlightViewModel(
      isEnabled: _nightlightViewModel.isEnabled,
      baselineIsEnabled: _nightlightViewModel.isEnabled,
      strength: _nightlightViewModel.strength,
      baselineStrength: _nightlightViewModel.strength,
      isIncluded: true,
      parent: this,
      nightlightViewModel: _nightlightViewModel,
    );
    _loadMonitorsForNewProfile();
  }

  EditProfileViewModel.editProfile({
    required String name,
    required NightlightViewModel nightlightViewModel,
    required MonitorsViewModel monitorsViewModel,
    required ProfilesViewModel profilesViewmodel,
  }) : _isNew = false,
       _oldName = name,
       _name = name,
       _preview = false,
       _nightlightViewModel = nightlightViewModel,
       _monitorsViewModel = monitorsViewModel,
       _profilesViewmodel = profilesViewmodel {
    final profile = _profilesViewmodel.getProfile(name);
    editProfileNightlightViewModel = profile.nightlightProfile != null
        ? EditProfileNightlightViewModel(
            isEnabled: profile.nightlightProfile!.isEnabled,
            baselineIsEnabled: _nightlightViewModel.isEnabled,
            strength: profile.nightlightProfile!.strength,
            baselineStrength: _nightlightViewModel.strength,
            isIncluded: true,
            parent: this,
            nightlightViewModel: _nightlightViewModel,
          )
        : EditProfileNightlightViewModel(
            isEnabled: _nightlightViewModel.isEnabled,
            baselineIsEnabled: _nightlightViewModel.isEnabled,
            strength: _nightlightViewModel.strength,
            baselineStrength: _nightlightViewModel.strength,
            isIncluded: false,
            parent: this,
            nightlightViewModel: _nightlightViewModel,
          );
    _loadMonitors(profile.monitorsProfile);
  }

  void _loadMonitorsForNewProfile() {
    for (final monitorViewModel in _monitorsViewModel.monitorViewModels) {
      editProfileMonitorViewModels.add(
        EditProfileMonitorViewModel(
          id: monitorViewModel.id,
          name: monitorViewModel.name,
          baselineBrightness: monitorViewModel.brightness,
          isIncluded: true,
          exists: true,
          parent: this,
          monitorViewModel: monitorViewModel,
        ),
      );
    }
  }

  void _loadMonitors(List<MonitorProfile> monitorsProfile) {
    for (final monitorViewModel in _monitorsViewModel.monitorViewModels) {
      editProfileMonitorViewModels.add(
        EditProfileMonitorViewModel(
          id: monitorViewModel.id,
          name: monitorViewModel.name,
          baselineBrightness: monitorViewModel.brightness,
          isIncluded: monitorsProfile.any((mp) => mp.id == monitorViewModel.id),
          exists: true,
          parent: this,
          monitorViewModel: monitorViewModel,
        ),
      );
    }
    final existingIds = _monitorsViewModel.monitorViewModels
        .map((mp) => mp.id)
        .toSet();
    for (final monitorProfile in monitorsProfile) {
      if (!existingIds.contains(monitorProfile.id)) {
        editProfileMonitorViewModels.add(
          EditProfileMonitorViewModel(
            id: monitorProfile.id,
            name: monitorProfile.id,
            baselineBrightness: monitorProfile.brightness,
            isIncluded: true,
            exists: false,
            parent: this,
          ),
        );
      }
    }
  }

  bool get preview => _preview;
  String get name => _name;
  bool get isNew => _isNew;

  void setPreview(bool preview) {
    _preview = preview;
    editProfileNightlightViewModel.onPreviewChange();
    for (var monitorCard in editProfileMonitorViewModels) {
      monitorCard.onPreviewChange();
    }
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void restoreBaseline() {
    editProfileNightlightViewModel.restoreBaseline();
    for (var monitorCard in editProfileMonitorViewModels) {
      monitorCard.restoreBaseline();
    }
  }

  void saveProfile() {
    final nightlightProfile = editProfileNightlightViewModel.isIncluded
        ? NightlightProfile(
            isEnabled: editProfileNightlightViewModel.isEnabled,
            strength: editProfileNightlightViewModel.strength,
          )
        : null;
    final monitorsProfile = editProfileMonitorViewModels
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
  }

  void removeMonitor(String id) {
    editProfileMonitorViewModels.removeWhere((vm) => vm.id == id);
    notifyListeners();
  }
}

class EditProfileNightlightViewModel extends ChangeNotifier {
  bool _isEnabled;
  final bool _baselineIsEnabled;
  double? _strength;
  final double? _baselineStrength;
  bool _isIncluded;
  final NightlightViewModel _nightlightViewModel;
  final EditProfileViewModel _parent;

  EditProfileNightlightViewModel({
    required bool isEnabled,
    required bool baselineIsEnabled,
    required double? strength,
    required double? baselineStrength,
    required bool isIncluded,
    required EditProfileViewModel parent,
    required NightlightViewModel nightlightViewModel,
  }) : _isEnabled = isEnabled,
       _baselineIsEnabled = baselineIsEnabled,
       _strength = strength,
       _baselineStrength = baselineStrength,
       _isIncluded = isIncluded,
       _parent = parent,
       _nightlightViewModel = nightlightViewModel;

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
      _nightlightViewModel.setActive(enabled);
    }
    notifyListeners();
  }

  void setStrength(double strength) {
    _strength = strength;
    if (_parent.preview) {
      _nightlightViewModel.setStrength(strength);
    }
    notifyListeners();
  }

  void onPreviewChange() {
    if (_parent.preview) {
      _nightlightViewModel.setActive(_isEnabled);
      if (_strength != null) {
        _nightlightViewModel.setStrength(_strength!);
      }
    } else {
      restoreBaseline();
    }
  }

  void restoreBaseline() {
    _nightlightViewModel.setActive(_baselineIsEnabled);
    if (_baselineStrength != null) {
      _nightlightViewModel.setStrength(_baselineStrength);
    }
  }
}

class EditProfileMonitorViewModel extends ChangeNotifier {
  final String id;
  final String name;
  final bool exists;
  double _brightness;
  final double _baselineBrightness;
  bool _isIncluded;
  final EditProfileViewModel _parent;
  final MonitorViewModel? _monitorViewModel;

  EditProfileMonitorViewModel({
    required this.id,
    required this.name,
    required double baselineBrightness,
    required bool isIncluded,
    required this.exists,
    required EditProfileViewModel parent,
    MonitorViewModel? monitorViewModel,
  }) : _brightness = monitorViewModel?.brightness ?? 0,
       _baselineBrightness = baselineBrightness,
       _isIncluded = isIncluded,
       _parent = parent,
       _monitorViewModel = monitorViewModel;

  double get brightness => _brightness;
  bool get isIncluded => _isIncluded;

  void setIncluded(bool included) {
    _isIncluded = included;
    notifyListeners();
  }

  void setBrightness(double brightness) {
    _brightness = brightness;
    if (_parent.preview) {
      _monitorViewModel?.setBrightness(brightness);
    }
    notifyListeners();
  }

  void onPreviewChange() {
    if (_parent.preview) {
      _monitorViewModel?.setBrightness(_brightness);
    } else {
      restoreBaseline();
    }
  }

  void restoreBaseline() {
    _monitorViewModel?.setBrightness(_baselineBrightness);
  }
}
