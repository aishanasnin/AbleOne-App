/// Domain entity representing user accessibility settings preferences.
class AccessibilitySettingsEntity {
  /// Toggle for high contrast color layouts.
  final bool highContrastMode;

  /// Toggle for large text configurations.
  final bool largeTextMode;

  /// Font scaling multiplier (e.g. 1.0, 1.2, 1.4).
  final double textScale;

  /// Toggle for speech-to-text/audio feedback features.
  final bool voiceEnabled;

  /// Reading narration speech speed multiplier (e.g. 1.0, 1.2).
  final double readingSpeed;

  /// Toggle for simplified clean interface layouts.
  final bool simplifiedMode;

  /// Creates an [AccessibilitySettingsEntity] instance.
  const AccessibilitySettingsEntity({
    required this.highContrastMode,
    required this.largeTextMode,
    required this.textScale,
    required this.voiceEnabled,
    required this.readingSpeed,
    required this.simplifiedMode,
  });

  /// Returns a copy of this entity with updated fields.
  AccessibilitySettingsEntity copyWith({
    bool? highContrastMode,
    bool? largeTextMode,
    double? textScale,
    bool? voiceEnabled,
    double? readingSpeed,
    bool? simplifiedMode,
  }) {
    return AccessibilitySettingsEntity(
      highContrastMode: highContrastMode ?? this.highContrastMode,
      largeTextMode: largeTextMode ?? this.largeTextMode,
      textScale: textScale ?? this.textScale,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      readingSpeed: readingSpeed ?? this.readingSpeed,
      simplifiedMode: simplifiedMode ?? this.simplifiedMode,
    );
  }

  /// Converts this entity into a Map for local database storage.
  Map<String, dynamic> toMap() {
    return {
      'highContrastMode': highContrastMode,
      'largeTextMode': largeTextMode,
      'textScale': textScale,
      'voiceEnabled': voiceEnabled,
      'readingSpeed': readingSpeed,
      'simplifiedMode': simplifiedMode,
    };
  }

  /// Rebuilds this entity from a Map.
  factory AccessibilitySettingsEntity.fromMap(Map<String, dynamic> map) {
    return AccessibilitySettingsEntity(
      highContrastMode: map['highContrastMode'] as bool? ?? false,
      largeTextMode: map['largeTextMode'] as bool? ?? false,
      textScale: (map['textScale'] as num?)?.toDouble() ?? 1.0,
      voiceEnabled: map['voiceEnabled'] as bool? ?? false,
      readingSpeed: (map['readingSpeed'] as num?)?.toDouble() ?? 1.0,
      simplifiedMode: map['simplifiedMode'] as bool? ?? false,
    );
  }
}
