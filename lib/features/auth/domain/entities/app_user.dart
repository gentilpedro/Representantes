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
}
