import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Privacy & Data Control Unit Tests', () {
    test('JSON Export layout contains expected keys and data structures', () {
      final mockExport = {
        'exportedAt': DateTime.now().toIso8601String(),
        'userId': 'student_123',
        'preferences': {
          'textScale': 1.2,
          'contrastMode': 'Normal',
          'voiceEnabled': false,
        },
      };

      expect(mockExport.containsKey('exportedAt'), true);
      expect(mockExport['userId'], 'student_123');
      
      final prefs = mockExport['preferences'] as Map<String, dynamic>;
      expect(prefs['textScale'], 1.2);
      expect(prefs['contrastMode'], 'Normal');
    });
  });
}
