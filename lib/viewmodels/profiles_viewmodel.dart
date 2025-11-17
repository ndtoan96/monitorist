import 'package:monitorist/services/profiles_service.dart';

class ProfilesPanelViewmodel {
  final ProfilesService _profilesService;
  ProfilesPanelViewmodel({required ProfilesService profilesService})
    : _profilesService = profilesService;
  List<String> get profileNames =>
      _profilesService.profiles.map((profile) => profile.name).toList();

  void deleteProfile(String name) {
    _profilesService.deleteProfile(name);
  }
}
