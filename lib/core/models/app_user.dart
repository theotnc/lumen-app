class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role; // user, contributor, moderator, admin
  final UserPreferences preferences;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'user',
    required this.preferences,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'user',
      preferences: UserPreferences.fromMap(
        (map['preferences'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'role': role,
        'preferences': preferences.toMap(),
        'createdAt': DateTime.now().toIso8601String(),
      };

  static AppUser empty(String uid, String email, {String displayName = ''}) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      preferences: UserPreferences.defaults(),
    );
  }
}

class UserPreferences {
  final List<int> notificationHours;
  final bool notificationEnabled;
  final List<String> bibleFavorites;
  final List<String> prayerFavorites;
  final List<String> churchFavorites;
  final double distanceRadius; // km

  const UserPreferences({
    required this.notificationHours,
    required this.notificationEnabled,
    required this.bibleFavorites,
    required this.prayerFavorites,
    required this.churchFavorites,
    required this.distanceRadius,
  });

  factory UserPreferences.defaults() => const UserPreferences(
        notificationHours: [12, 18],
        notificationEnabled: true,
        bibleFavorites: [],
        prayerFavorites: [],
        churchFavorites: [],
        distanceRadius: 10.0,
      );

  factory UserPreferences.fromMap(Map<String, dynamic> map) => UserPreferences(
        notificationHours: List<int>.from(map['notificationHours'] ?? [12, 18]),
        notificationEnabled: map['notificationEnabled'] ?? true,
        bibleFavorites: List<String>.from(map['bibleFavorites'] ?? []),
        prayerFavorites: List<String>.from(map['prayerFavorites'] ?? []),
        churchFavorites: List<String>.from(map['churchFavorites'] ?? []),
        distanceRadius: (map['distanceRadius'] ?? 10.0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'notificationHours': notificationHours,
        'notificationEnabled': notificationEnabled,
        'bibleFavorites': bibleFavorites,
        'prayerFavorites': prayerFavorites,
        'churchFavorites': churchFavorites,
        'distanceRadius': distanceRadius,
      };

  UserPreferences copyWith({
    List<int>? notificationHours,
    bool? notificationEnabled,
    double? distanceRadius,
  }) =>
      UserPreferences(
        notificationHours: notificationHours ?? this.notificationHours,
        notificationEnabled: notificationEnabled ?? this.notificationEnabled,
        bibleFavorites: bibleFavorites,
        prayerFavorites: prayerFavorites,
        churchFavorites: churchFavorites,
        distanceRadius: distanceRadius ?? this.distanceRadius,
      );
}
