import 'package:ableone_app/features/accessibility/domain/entities/accessibility_settings_entity.dart';

/// Repository interface defining accessibility preference loading and saving.
abstract class AccessibilityRepository {
  /// Fetches saved user accessibility preferences.
  Future<AccessibilitySettingsEntity> getSettings();

  /// Saves updated accessibility preferences locally.
  Future<void> saveSettings(AccessibilitySettingsEntity settings);
}
