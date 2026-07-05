class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.region,
    required this.appVersion,
    this.avatarUrl,
    this.lastSyncAt,
  });

  final String id;
  final String name;
  final String role;
  final String region;
  final String appVersion;
  final String? avatarUrl;
  final DateTime? lastSyncAt;

  /// Usado para cachear o perfil localmente (ver [SessionStorage]) e
  /// restaurar a sessão sem depender de um endpoint `/me`, que a Web API
  /// ainda não expõe.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'region': region,
    'appVersion': appVersion,
    'avatarUrl': avatarUrl,
    'lastSyncAt': lastSyncAt?.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    role: json['role'] as String,
    region: json['region'] as String,
    appVersion: json['appVersion'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    lastSyncAt: json['lastSyncAt'] == null
        ? null
        : DateTime.parse(json['lastSyncAt'] as String),
  );
}
