import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/app.dart';

void main() {
  testWidgets('Splash page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AbleOneApp(),
      ),
    );

    // Verify that Splash Page elements are rendered
    expect(find.text('AbleOne'), findsOneWidget);
  });
}
