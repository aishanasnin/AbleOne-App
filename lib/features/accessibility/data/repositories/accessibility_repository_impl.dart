import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/features/accessibility/domain/entities/accessibility_settings_entity.dart';
import 'package:ableone_app/features/accessibility/domain/repositories/accessibility_repository.dart';
import 'package:ableone_app/features/accessibility/data/models/accessibility_model.dart';

/// Hive implementation of [AccessibilityRepository] with StateNotifier for settings preferences.
class AccessibilityRepositoryImpl implements AccessibilityRepository {
  final String _boxName = 'accessibility_settings';
  final String _key = 'settings';

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  @override
  Future<AccessibilitySettingsEntity> getSettings() async {
    try {
      final box = await _openBox();
      final data = box.get(_key);
      if (data != null) {
        return AccessibilityModel.fromMap(Map<String, dynamic>.from(data as Map));
      }
      return const AccessibilityModel(
        textScale: 1.0,
        contrastMode: 'Normal',
        voiceEnabled: false,
        readingSpeed: 1.0,
        simplifiedMode: false,
        animationEnabled: true,
        stepByStepMode: false,
      );
    } catch (_) {
      return const AccessibilityModel(
        textScale: 1.0,
        contrastMode: 'Normal',
        voiceEnabled: false,
        readingSpeed: 1.0,
        simplifiedMode: false,
        animationEnabled: true,
        stepByStepMode: false,
      );
    }
  }

  @override
  Future<void> saveSettings(AccessibilitySettingsEntity settings) async {
    try {
      final box = await _openBox();
      final model = AccessibilityModel(
        textScale: settings.textScale,
        contrastMode: settings.contrastMode,
        voiceEnabled: settings.voiceEnabled,
        readingSpeed: settings.readingSpeed,
        simplifiedMode: settings.simplifiedMode,
        animationEnabled: settings.animationEnabled,
        stepByStepMode: settings.stepByStepMode,
      );
      await box.put(_key, model.toMap());
    } catch (e) {
      throw Exception('Failed to save accessibility settings: ${e.toString()}');
    }
  }
}

// Riverpod Providers

/// Provider exposing the accessibility settings repository implementation.
final accessibilityRepositoryProvider = Provider<AccessibilityRepository>((ref) {
  return AccessibilityRepositoryImpl();
});

/// StateNotifier managing global accessibility settings state changes and storage updates.
class AccessibilitySettingsNotifier extends StateNotifier<AccessibilitySettingsEntity> {
  final AccessibilityRepository _repository;

  /// Creates an [AccessibilitySettingsNotifier] instance.
  AccessibilitySettingsNotifier(this._repository)
      : super(const AccessibilityModel(
          textScale: 1.0,
          contrastMode: 'Normal',
          voiceEnabled: false,
          readingSpeed: 1.0,
          simplifiedMode: false,
          animationEnabled: true,
          stepByStepMode: false,
        )) {
    loadSettings();
  }

  /// Loads accessibility settings from storage.
  Future<void> loadSettings() async {
    final settings = await _repository.getSettings();
    state = settings;
  }

  /// Updates settings state.
  Future<void> updateSettings(AccessibilitySettingsEntity updated) async {
    state = updated;
    await _repository.saveSettings(updated);
  }

  /// Sets the contrast theme mode preference.
  Future<void> setContrastMode(String mode) async {
    final updated = state.copyWith(contrastMode: mode);
    await updateSettings(updated);
  }

  /// Backward compatible toggle helper for high contrast mode.
  Future<void> toggleHighContrast() async {
    final nextContrast = state.contrastMode == 'High Contrast' ? 'Normal' : 'High Contrast';
    await setContrastMode(nextContrast);
  }

  /// Backward compatible large text toggle helper.
  Future<void> toggleLargeText() async {
    final currentScale = state.textScale;
    final nextScale = currentScale > 1.1 ? 1.0 : 1.3;
    await setTextScale(nextScale);
  }

  /// Toggles narration audio feedback.
  Future<void> toggleVoice() async {
    final updated = state.copyWith(voiceEnabled: !state.voiceEnabled);
    await updateSettings(updated);
  }

  /// Toggles simplified clean interface layout.
  Future<void> toggleSimplified() async {
    final updated = state.copyWith(simplifiedMode: !state.simplifiedMode);
    await updateSettings(updated);
  }

  /// Toggles UI animation transitions.
  Future<void> toggleAnimation() async {
    final updated = state.copyWith(animationEnabled: !state.animationEnabled);
    await updateSettings(updated);
  }

  /// Toggles step-by-step presentation format.
  Future<void> toggleStepByStep() async {
    final updated = state.copyWith(stepByStepMode: !state.stepByStepMode);
    await updateSettings(updated);
  }

  /// Dynamically sets the text scaling multiplier.
  Future<void> setTextScale(double scale) async {
    final updated = state.copyWith(textScale: scale);
    await updateSettings(updated);
  }

  /// Dynamically sets the narration voice speed.
  Future<void> setReadingSpeed(double speed) async {
    final updated = state.copyWith(readingSpeed: speed);
    await updateSettings(updated);
  }
}

/// Provider managing active accessibility settings profiles.
final accessibilitySettingsProvider = StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettingsEntity>((ref) {
  final repo = ref.watch(accessibilityRepositoryProvider);
  return AccessibilitySettingsNotifier(repo);
});
