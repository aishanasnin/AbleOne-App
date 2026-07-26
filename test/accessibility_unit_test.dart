import 'package:flutter_test/flutter_test.dart';
import 'package:ableone_app/features/accessibility/data/models/accessibility_model.dart';

void main() {
  group('Accessibility Model & Settings Tests', () {
    test('AccessibilityModel should build from default constructor parameters correctly', () {
      const model = AccessibilityModel(
        textScale: 1.2,
        contrastMode: 'High Contrast',
        voiceEnabled: true,
        readingSpeed: 1.5,
        simplifiedMode: true,
        animationEnabled: false,
        stepByStepMode: true,
      );

      expect(model.textScale, 1.2);
      expect(model.contrastMode, 'High Contrast');
      expect(model.voiceEnabled, true);
      expect(model.readingSpeed, 1.5);
      expect(model.simplifiedMode, true);
      expect(model.animationEnabled, false);
      expect(model.stepByStepMode, true);
      expect(model.highContrastMode, true);
      expect(model.largeTextMode, true);
    });

    test('AccessibilityModel should map serialization fields correctly to/from Map', () {
      final map = {
        'textScale': 1.4,
        'contrastMode': 'High Contrast',
        'voiceEnabled': true,
        'readingSpeed': 1.2,
        'simplifiedMode': false,
        'animationEnabled': false,
        'stepByStepMode': true,
      };

      final parsed = AccessibilityModel.fromMap(map);

      expect(parsed.textScale, 1.4);
      expect(parsed.contrastMode, 'High Contrast');
      expect(parsed.voiceEnabled, true);
      expect(parsed.readingSpeed, 1.2);
      expect(parsed.simplifiedMode, false);
      expect(parsed.animationEnabled, false);
      expect(parsed.stepByStepMode, true);

      final outMap = parsed.toMap();
      expect(outMap['textScale'], 1.4);
      expect(outMap['contrastMode'], 'High Contrast');
      expect(outMap['animationEnabled'], false);
    });
  });
}
