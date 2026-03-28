import 'package:flutter_test/flutter_test.dart';
import '../lib/features/teacher/create_session/session_code_generator.dart';

void main() {
  group('SessionCodeGenerator Tests', () {
    test('generates a 4-character code', () async {
      final code = await SessionCodeGenerator.generateUniqueCode();
      expect(code.length, 4);
    });

    test('code contains only valid alphanumeric characters', () async {
      final code = await SessionCodeGenerator.generateUniqueCode();
      final validChars = RegExp(r'^[A-Z0-9]{4}$');
      expect(validChars.hasMatch(code), isTrue);
    });
  });
}
