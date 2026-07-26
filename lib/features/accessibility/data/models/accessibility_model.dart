import 'package:ableone_app/features/accessibility/domain/entities/accessibility_settings_entity.dart';

class AccessibilityModel extends AccessibilitySettingsEntity {
  const AccessibilityModel({
    required super.textScale,
    required super.contrastMode,
    required super.voiceEnabled,
    required super.readingSpeed,
    required super.simplifiedMode,
    required super.animationEnabled,
    super.stepByStepMode = false,
  });

  factory AccessibilityModel.fromMap(Map<String, dynamic> map) {
    return AccessibilityModel(
      textScale: (map['textScale'] as num?)?.toDouble() ?? 1.0,
      contrastMode: map['contrastMode'] as String? ?? 'Normal',
      voiceEnabled: map['voiceEnabled'] as bool? ?? false,
      readingSpeed: (map['readingSpeed'] as num?)?.toDouble() ?? 1.0,
      simplifiedMode: map['simplifiedMode'] as bool? ?? false,
      animationEnabled: map['animationEnabled'] as bool? ?? true,
      stepByStepMode: map['stepByStepMode'] as bool? ?? false,
    );
  }

  @override
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
}
