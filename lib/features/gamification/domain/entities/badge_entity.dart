class BadgeEntity {
  final String id;
  final String title;
  final String description;
  final String icon; // Icon name key
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const BadgeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAt,
  });
}
