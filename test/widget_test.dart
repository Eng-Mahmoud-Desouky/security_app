import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_app/core/alphabets/predefined_domains.dart';
import 'package:security_app/domain/ciphers/caesar_cipher_engine.dart';
import 'package:security_app/domain/ciphers/vigenere_cipher_engine.dart';
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

  test('VigenereCipherEngine encrypts, decrypts, and traces accurately', () {
    const engine = VigenereCipherEngine();

    final encrypted = engine.encryptWithKeyword(
      'Hello World',
      keyword: 'KEY',
      preserveSpaces: true,
    );
    expect(encrypted.validationMessage, isNull);
    expect(encrypted.outputText, 'Rijvs Uyvjn');
    expect(encrypted.traceSteps[0].formula, '[K=10] (7 + 10) mod 26 = 17');
    expect(encrypted.traceSteps[1].formula, '[E=4] (4 + 4) mod 26 = 8');
    expect(encrypted.traceSteps[5].isBypassed, isTrue);
    expect(encrypted.traceSteps[5].inputChar, ' ');
    // Space must NOT increment keyStep, so 'W' uses 'Y' (k=24)
    expect(encrypted.traceSteps[6].formula, '[Y=24] (22 + 24) mod 26 = 20');

    final decrypted = engine.decryptWithKeyword(
      'Rijvs Uyvjn',
      keyword: 'KEY',
      preserveSpaces: true,
    );
    expect(decrypted.validationMessage, isNull);
    expect(decrypted.outputText, 'Hello World');
    expect(decrypted.traceSteps[0].formula, '[K=10] (17 - 10) mod 26 = 7');
  });

  test('VigenereCipherEngine ignores keyword spaces/unknowns and supports emojis',
      () {
    const engine = VigenereCipherEngine();

    // Keyword ' K ❤️ ' -> cleaned tokens: K(10), ❤️(10)
    final encrypted = engine.encryptWithKeyword(
      'A 🛡️',
      keyword: ' K ❤️ ',
      preserveSpaces: true,
    );
    expect(encrypted.outputText, 'K 👍');
    expect(encrypted.traceSteps[0].formula, '[K=10] (0 + 10) mod 26 = 10');
    expect(encrypted.traceSteps[1].isBypassed, isTrue);
    expect(encrypted.traceSteps[2].formula, '[❤️=10] (18 + 10) mod 20 = 8');

    final decrypted = engine.decryptWithKeyword(
      encrypted.outputText,
      keyword: ' K ❤️ ',
      preserveSpaces: true,
    );
    expect(decrypted.outputText, 'A 🛡️');

    // Empty/whitespace keyword returns input unchanged with validation message
    final emptyKeyResult = engine.encryptWithKeyword(
      'Hello',
      keyword: '   ',
      preserveSpaces: true,
    );
    expect(emptyKeyResult.outputText, 'Hello');
    expect(
      emptyKeyResult.validationMessage,
      VigenereCipherEngine.emptyKeywordValidationMessage,
    );
    expect(emptyKeyResult.traceSteps.every((step) => step.isBypassed), isTrue);
  });

  testWidgets('MultiDomainCipherApp renders workspace without layout errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MultiDomainCipherApp());
    expect(find.text('Multi-Domain Caesar Cipher'), findsOneWidget);
    expect(find.text('Plaintext Input'), findsOneWidget);
  });

  testWidgets(
      'Switching to Vigenere disables Crack mode and switches Crack to Encrypt',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MultiDomainCipherApp());

    // Enter Crack mode in Caesar
    await tester.tap(find.text('Crack (Brute-Force)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Smart Brute-Force Bound'), findsOneWidget);

    // Switch to Vigenere Cipher
    await tester.tap(find.text('Vigenère Cipher'));
    await tester.pumpAndSettle();

    expect(find.text('Multi-Domain Vigenère Cipher'), findsOneWidget);
    expect(find.text('Polyalphabetic Keyword'), findsOneWidget);
    expect(find.textContaining('Smart Brute-Force Bound'), findsNothing);
    expect(find.text('Plaintext Input'), findsOneWidget);

    // Verify Crack segment is disabled in Vigenere mode
    final segmentedButton = tester.widget<SegmentedButton<dynamic>>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SegmentedButton &&
            widget.segments.any((s) => s.label is Text && (s.label as Text).data == 'Crack (Brute-Force)'),
      ),
    );
    final crackSegment = segmentedButton.segments.firstWhere(
      (s) => s.label is Text && (s.label as Text).data == 'Crack (Brute-Force)',
    );
    expect(crackSegment.enabled, isFalse);

    // Tapping disabled Crack segment keeps Encrypt mode active
    await tester.tap(find.text('Crack (Brute-Force)'));
    await tester.pumpAndSettle();
    expect(find.text('Plaintext Input'), findsOneWidget);
    expect(find.textContaining('Smart Brute-Force Bound'), findsNothing);
  });
}
