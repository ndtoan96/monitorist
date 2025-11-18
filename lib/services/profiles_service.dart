import 'dart:collection';
import 'dart:convert';

import 'package:monitorist/models/profile.dart';
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

  /// Adds a profile to the list.
  /// 
  /// @throws [Exception] if the profile name is empty or already exists.
  void addProfile(Profile profile) {
    if (profile.name.isEmpty) {
      throw ProfileException('Profile name cannot be empty.');
    }
    if (_profiles.any((p) => p.name == profile.name)) {
      throw ProfileException('Profile with name ${profile.name} already exists.');
    }
    _profiles.add(profile);
    _save();
  }

  /// Updates an existing profile.
  /// 
  /// @throws [Exception] if the new profile name is empty or already exists.
  void updateProfile({required String name, required Profile newProfile}) {
    if (newProfile.name.isEmpty) {
      throw ProfileException('Profile name cannot be empty.');
    }
    if (newProfile.name != name &&
        _profiles.any((p) => p.name == newProfile.name)) {
      throw ProfileException('Profile with name ${newProfile.name} already exists.');
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

class ProfileException implements Exception {
  final String message;
  ProfileException(this.message);

  @override
  String toString() => 'ProfileException: $message';
}