import 'package:monitorist/models/profile.dart';
import 'package:monitorist/services/profiles_service.dart';
import 'package:flutter/foundation.dart';
import 'package:monitorist/viewmodels/monitors_viewmodel.dart';
import 'package:monitorist/viewmodels/nightlight_viewmodel.dart';

class ProfilesViewModel extends ChangeNotifier {
  final ProfilesService _profilesService;
  final NightlightViewModel _nightlightViewModel;
  final MonitorsViewModel _monitorsViewModel;

  ProfilesViewModel({
    required ProfilesService profilesService,
    required NightlightViewModel nightlightViewModel,
    required MonitorsViewModel monitorsViewModel,
  }) : _profilesService = profilesService,
       _nightlightViewModel = nightlightViewModel,
       _monitorsViewModel = monitorsViewModel;

  List<Profile> get profiles => _profilesService.profiles;

  Profile getProfile(String name) {
    return _profilesService.getProfile(name);
  }

  void addProfile(Profile profile) {
    _profilesService.addProfile(profile);
    notifyListeners();
  }

  void deleteProfile(String name) {
    _profilesService.deleteProfile(name);
    notifyListeners();
  }

  void updateProfile({required String name, required Profile newProfile}) {
    _profilesService.updateProfile(name: name, newProfile: newProfile);
    notifyListeners();
  }

  void applyProfile(String name) {
    final profile = _profilesService.getProfile(name);
    if (profile.nightlightProfile != null) {
      _nightlightViewModel.setActive(profile.nightlightProfile!.isEnabled);
      if (profile.nightlightProfile!.strength != null) {
        _nightlightViewModel.setStrength(profile.nightlightProfile!.strength!);
      }
    }
    for (final monitor in _monitorsViewModel.monitorViewModels) {
      final monitorProfile = profile.monitorsProfile.where( (p) => p.id == monitor.id).firstOrNull;
      if (monitorProfile != null) {
        monitor.setBrightness(monitorProfile.brightness);
      }
    }
  }
}
