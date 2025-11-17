import 'dart:collection';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'dart:io';

class ProfilesService {
  final File _storageFile;
  late List<Profile> _profiles;

  ProfilesService()
    : _storageFile = File(
        p.join(Platform.environment['APPDATA']!, 'Monitorist', 'profiles.json'),
      ) {
    _profiles = _getProfiles();
  }

  UnmodifiableListView<Profile> get profiles => UnmodifiableListView(_profiles);

  List<Profile> _getProfiles() {
    if (!_storageFile.existsSync()) {
      return [];
    } else {
      final content = _storageFile.readAsStringSync();
      final List<dynamic> jsonData = content.isNotEmpty
          ? jsonDecode(content)
          : [];
      return jsonData.map((json) => Profile.fromJson(json)).toList();
    }
  }

  void _save() {
    final jsonData = _profiles.map((profile) => profile.toJson()).toList();
    final content = jsonEncode(jsonData);
    _storageFile.createSync(recursive: true);
    _storageFile.writeAsStringSync(content);
  }

  void addProfile(Profile profile) {
    if (profile.name.isEmpty) {
      throw Exception('Profile name cannot be empty.');
    }
    if (_profiles.any((p) => p.name == profile.name)) {
      throw Exception('Profile with name ${profile.name} already exists.');
    }
    _profiles.add(profile);
    _save();
  }

  void updateProfile({required String name, required Profile newProfile}) {
    if (newProfile.name.isEmpty) {
      throw Exception('Profile name cannot be empty.');
    }
    if (newProfile.name != name &&
        _profiles.any((p) => p.name == newProfile.name)) {
      throw Exception('Profile with name ${newProfile.name} already exists.');
    }
    final index = _profiles.indexWhere((p) => p.name == name);
    if (index != -1) {
      _profiles[index] = newProfile;
      _save();
    }
  }

  void deleteProfile(String name) {
    _profiles.removeWhere((p) => p.name == name);
    _save();
  }

  Profile getProfile(String name) {
    return _profiles.firstWhere((p) => p.name == name);
  }
}

class Profile {
  final String name;
  final NightlightProfile? nightlightProfile;
  final List<MonitorProfile> monitorsProfile;

  Profile({
    required this.name,
    required this.nightlightProfile,
    required this.monitorsProfile,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'],
      nightlightProfile: json['nightlightProfile'] != null
          ? NightlightProfile.fromJson(json['nightlightProfile'])
          : null,
      monitorsProfile: (json['monitorsProfile'] as List)
          .map((monitorJson) => MonitorProfile.fromJson(monitorJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nightlightProfile': nightlightProfile?.toJson(),
      'monitorsProfile': monitorsProfile
          .map((monitor) => monitor.toJson())
          .toList(),
    };
  }
}

class NightlightProfile {
  final bool isEnabled;
  final double? strength;

  NightlightProfile({required this.isEnabled, required this.strength});
  factory NightlightProfile.fromJson(Map<String, dynamic> json) {
    return NightlightProfile(
      isEnabled: json['isEnabled'],
      strength: json['strength'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'isEnabled': isEnabled, 'strength': strength};
  }
}

class MonitorProfile {
  final String id;
  final double brightness;

  MonitorProfile({required this.id, required this.brightness});
  factory MonitorProfile.fromJson(Map<String, dynamic> json) {
    return MonitorProfile(id: json['id'], brightness: json['brightness']);
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'brightness': brightness};
  }
}
