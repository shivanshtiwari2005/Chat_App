class AppUser {
  final String uid;
  final String name;
  final bool isOnline;
  final int? lastSeen;
  final String? avatarUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.isOnline,
    this.lastSeen,
    this.avatarUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      name: map['name'] as String,
      isOnline: (map['isOnline'] ?? false) as bool,
      lastSeen: map['lastSeen'] is int ? map['lastSeen'] as int? : (map['lastSeen'] != null ? (map['lastSeen'] as num).toInt() : null),
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'isOnline': isOnline,
        'lastSeen': lastSeen,
        'avatarUrl': avatarUrl,
      };
}