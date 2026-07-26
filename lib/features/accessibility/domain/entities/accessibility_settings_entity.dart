/// Domain entity representing user accessibility settings preferences.
class AccessibilitySettingsEntity {
  /// Font scaling multiplier (e.g. 1.0, 1.2, 1.4).
  final double textScale;

  /// Contrast theme mode preference (e.g. 'Normal', 'High Contrast').
  final String contrastMode;

  /// Toggle for speech-to-text/audio feedback features.
  final bool voiceEnabled;

  /// Reading narration speech speed multiplier (e.g. 1.0, 1.2).
  final double readingSpeed;

  /// Toggle for simplified clean interface layouts.
  final bool simplifiedMode;

  /// Toggle for UI animations (e.g. disables heavy transitions).
  final bool animationEnabled;

  /// Toggle for presenting content in structured step-by-step lists.
  final bool stepByStepMode;

  /// Creates an [AccessibilitySettingsEntity] instance.
  const AccessibilitySettingsEntity({
    required this.textScale,
    required this.contrastMode,
    required this.voiceEnabled,
    required this.readingSpeed,
    required this.simplifiedMode,
    required this.animationEnabled,
    this.stepByStepMode = false,
  });

  /// Backward compatible helper returning true if contrastMode is 'High Contrast'.
  bool get highContrastMode => contrastMode == 'High Contrast';

  /// Backward compatible helper returning true if textScale is enlarged.
  bool get largeTextMode => textScale > 1.1;

  /// Returns a copy of this entity with updated fields.
  AccessibilitySettingsEntity copyWith({
    double? textScale,
    String? contrastMode,
    bool? voiceEnabled,
    double? readingSpeed,
    bool? simplifiedMode,
    bool? animationEnabled,
    bool? stepByStepMode,
  }) {
    return AccessibilitySettingsEntity(
      textScale: textScale ?? this.textScale,
      contrastMode: contrastMode ?? this.contrastMode,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      readingSpeed: readingSpeed ?? this.readingSpeed,
      simplifiedMode: simplifiedMode ?? this.simplifiedMode,
      animationEnabled: animationEnabled ?? this.animationEnabled,
      stepByStepMode: stepByStepMode ?? this.stepByStepMode,
    );
  }

  /// Converts this entity into a Map for local database storage.
  Map<String, dynamic> toMap() {
    return {
      'textScale': textScale,
      'contrastMode': contrastMode,
      'voiceEnabled': voiceEnabled,
      'readingSpeed': readingSpeed,
      'simplifiedMode': simplifiedMode,
      'animationEnabled': animationEnabled,
      'stepByStepMode': stepByStepMode,
    };
  }

  /// Rebuilds this entity from a Map.
  factory AccessibilitySettingsEntity.fromMap(Map<String, dynamic> map) {
    return AccessibilitySettingsEntity(
      textScale: (map['textScale'] as num?)?.toDouble() ?? 1.0,
      contrastMode: map['contrastMode'] as String? ?? 'Normal',
      voiceEnabled: map['voiceEnabled'] as bool? ?? false,
      readingSpeed: (map['readingSpeed'] as num?)?.toDouble() ?? 1.0,
      simplifiedMode: map['simplifiedMode'] as bool? ?? false,
      animationEnabled: map['animationEnabled'] as bool? ?? true,
      stepByStepMode: map['stepByStepMode'] as bool? ?? false,
    );
  }
}
