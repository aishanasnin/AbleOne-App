import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/app.dart';
import 'package:ableone_app/features/accessibility/domain/entities/accessibility_settings_entity.dart';
import 'package:ableone_app/features/accessibility/domain/repositories/accessibility_repository.dart';
import 'package:ableone_app/features/accessibility/data/repositories/accessibility_repository_impl.dart';

class FakeAccessibilityRepository implements AccessibilityRepository {
  @override
  Future<AccessibilitySettingsEntity> getSettings() async {
    return const AccessibilitySettingsEntity(
      textScale: 1.0,
      contrastMode: 'Normal',
      voiceEnabled: false,
      readingSpeed: 1.0,
      simplifiedMode: false,
      animationEnabled: true,
      stepByStepMode: false,
    );
  }

  @override
  Future<void> saveSettings(AccessibilitySettingsEntity settings) async {}
}

void main() {
  testWidgets('Splash page smoke test', (WidgetTester tester) async {
    // Build our app with a mocked repository provider to avoid Hive initialization errors.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessibilityRepositoryProvider.overrideWithValue(FakeAccessibilityRepository()),
        ],
        child: const AbleOneApp(),
      ),
    );

    // Verify that Splash Page elements are rendered
    expect(find.text('AbleOne'), findsOneWidget);

    // Let the auto-navigation timer complete before finishing
    await tester.pump(const Duration(seconds: 3));
  });
}
