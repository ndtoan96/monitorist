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
