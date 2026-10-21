import 'package:flutter_test/flutter_test.dart';
import 'package:security_app/core/alphabets/predefined_domains.dart';
import 'package:security_app/domain/ciphers/caesar_cipher_engine.dart';
import 'package:security_app/main.dart';

void main() {
  test('All 10 predefined domains match exact SRS modulus N', () {
    expect(PredefinedDomains.domAr.modulus, 36);
    expect(PredefinedDomains.domEnUpper.modulus, 26);
    expect(PredefinedDomains.domEnLower.modulus, 26);
    expect(PredefinedDomains.domEsExt.modulus, 7);
    expect(PredefinedDomains.domRu.modulus, 33);
    expect(PredefinedDomains.domGr.modulus, 24);
    expect(PredefinedDomains.domHe.modulus, 22);
    expect(PredefinedDomains.domNum.modulus, 10);
    expect(PredefinedDomains.domSym.modulus, 32);
    expect(PredefinedDomains.domEmoji.modulus, 20);
  });

  test('CaesarCipherEngine handles multi-codepoint emojis & space toggle', () {
    const engine = CaesarCipherEngine();

    // Index 10 is ❤️, Index 18 is 🛡️ in DOM_EMOJI (N=20)
    final encryptedEmoji = engine.encrypt('❤️🛡️', key: 3, preserveSpaces: true);
    // (10 + 3) mod 20 = 13 (🎉), (18 + 3) mod 20 = 1 (😂)
    expect(encryptedEmoji.outputText, '🎉😂');
    expect(encryptedEmoji.traceSteps.first.formula, '(10 + 3) mod 20 = 13');

    // Space preserved when preserveSpaces is true
    final preservedSpace = engine.encrypt('A B', key: 1, preserveSpaces: true);
    expect(preservedSpace.outputText, 'B C');

    // Space routed to DOM_SYM index 0 when preserveSpaces is false: (0 + 3) mod 32 = 3 ('#')
    final shiftedSpace = engine.encrypt(' ', key: 3, preserveSpaces: false);
    expect(shiftedSpace.outputText, '#');
  });

  testWidgets('MultiDomainCipherApp renders workspace without layout errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MultiDomainCipherApp());
    expect(find.text('Multi-Domain Caesar Cipher'), findsOneWidget);
    expect(find.text('Plaintext Input'), findsOneWidget);
  });
}
