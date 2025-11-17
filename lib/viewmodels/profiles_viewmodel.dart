import 'package:monitorist/services/profiles_service.dart';
import 'package:flutter/foundation.dart';

class ProfilesViewmodel extends ChangeNotifier {
  final ProfilesService _profilesService;
  ProfilesViewmodel({required ProfilesService profilesService})
    : _profilesService = profilesService;

  List<Profile> get profiles => _profilesService.profiles;

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
}
