import 'dart:math' as math;
import 'package:characters/characters.dart';
import 'package:equatable/equatable.dart';
import '../../core/alphabets/character_domain.dart';
import '../../core/alphabets/predefined_domains.dart';
import '../entities/brute_force_candidate.dart';
import '../entities/char_trace_step.dart';
import '../entities/cipher_process_result.dart';
import 'cipher_engine.dart';

/// Parsed grapheme token from a Vigenère keyword mapped to its domain and index K.
class VigenereKeyToken extends Equatable {
  final String grapheme;
  final CharacterDomain domain;
  final int keyIndex;

  const VigenereKeyToken({
    required this.grapheme,
    required this.domain,
    required this.keyIndex,
  });

  @override
  List<Object?> get props => [grapheme, domain, keyIndex];
}

/// Multi-Domain Vigenère Cipher implementation with grapheme-aware keyword routing.
class VigenereCipherEngine extends CipherEngine {
  static const int defaultFallbackModulus = 36;
  static const String emptyKeywordValidationMessage =
      'Invalid Keyword: Please enter at least one valid domain character. Input returned unchanged.';

  const VigenereCipherEngine();

  @override
  String get id => 'vigenere_multi_domain';

  @override
  String get name => 'Multi-Domain Vigenère Cipher';

  @override
  String get description =>
      'C = ((P + K_i) mod N_D + N_D) mod N_D  |  P = ((C - K_i) mod N_D + N_D) mod N_D';

  /// Positive mathematical modulo in Dart: ((p + shift) % n + n) % n
  int positiveModulo(int p, int shift, int n) {
    return ((p + shift) % n + n) % n;
  }

  /// Parses [keyword] into valid domain-mapped graphemes (`keyGraphemes`).
  /// When [preserveSpaces] is `true`, spaces `' '` and unknown characters are ignored.
  /// When [preserveSpaces] is `false`, `' '` resolves to `DOM_SYM` (index 0) while
  /// unknown characters outside all 10 domains are still ignored.
  List<VigenereKeyToken> parseKeyword(
    String keyword, {
    required bool preserveSpaces,
  }) {
    if (keyword.isEmpty) return const [];

    final List<VigenereKeyToken> tokens = <VigenereKeyToken>[];
    for (final String grapheme in keyword.characters) {
      final CharacterDomain? domain = PredefinedDomains.resolveDomain(
        grapheme,
        preserveSpaces: preserveSpaces,
      );
      if (domain == null) {
        continue;
      }
      final int? keyIndex = domain.indexOf(grapheme);
      if (keyIndex == null) {
        continue;
      }
      tokens.add(
        VigenereKeyToken(
          grapheme: grapheme,
          domain: domain,
          keyIndex: keyIndex,
        ),
      );
    }
    return List<VigenereKeyToken>.unmodifiable(tokens);
  }

  @override
  List<CharacterDomain> detectDomains(
    String inputText, {
    required bool preserveSpaces,
  }) {
    if (inputText.isEmpty) return const [];

    final Set<String> seenIds = <String>{};
    final List<CharacterDomain> detected = <CharacterDomain>[];

    for (final String grapheme in inputText.characters) {
      final CharacterDomain? domain = PredefinedDomains.resolveDomain(
        grapheme,
        preserveSpaces: preserveSpaces,
      );
      if (domain != null && seenIds.add(domain.id)) {
        detected.add(domain);
      }
    }

    return List<CharacterDomain>.unmodifiable(detected);
  }

  @override
  int calculateMaxModulus(List<CharacterDomain> detectedDomains) {
    if (detectedDomains.isEmpty) {
      return defaultFallbackModulus;
    }
    return detectedDomains.map((d) => d.modulus).reduce(math.max);
  }

  /// Encrypts [inputText] with multi-domain polyalphabetic [keyword].
  CipherProcessResult encryptWithKeyword(
    String inputText, {
    required String keyword,
    required bool preserveSpaces,
  }) {
    return _processWithKeyword(
      inputText: inputText,
      keyword: keyword,
      isEncrypt: true,
      preserveSpaces: preserveSpaces,
    );
  }

  /// Decrypts [inputText] with multi-domain polyalphabetic [keyword].
  CipherProcessResult decryptWithKeyword(
    String inputText, {
    required String keyword,
    required bool preserveSpaces,
  }) {
    return _processWithKeyword(
      inputText: inputText,
      keyword: keyword,
      isEncrypt: false,
      preserveSpaces: preserveSpaces,
    );
  }

  @override
  CipherProcessResult encrypt(
    String inputText, {
    required int key,
    required bool preserveSpaces,
  }) {
    return encryptWithKeyword(
      inputText,
      keyword: key.toString(),
      preserveSpaces: preserveSpaces,
    );
  }

  @override
  CipherProcessResult decrypt(
    String inputText, {
    required int key,
    required bool preserveSpaces,
  }) {
    return decryptWithKeyword(
      inputText,
      keyword: key.toString(),
      preserveSpaces: preserveSpaces,
    );
  }

  @override
  List<BruteForceCandidate> crack(
    String inputText, {
    required bool preserveSpaces,
  }) {
    return const [];
  }

  CipherProcessResult _processWithKeyword({
    required String inputText,
    required String keyword,
    required bool isEncrypt,
    required bool preserveSpaces,
  }) {
    final List<VigenereKeyToken> keyTokens = parseKeyword(
      keyword,
      preserveSpaces: preserveSpaces,
    );

    if (keyTokens.isEmpty) {
      if (inputText.isEmpty) {
        return const CipherProcessResult(
          outputText: '',
          traceSteps: [],
          detectedDomains: [],
          validationMessage: emptyKeywordValidationMessage,
        );
      }

      final List<CharTraceStep> bypassedSteps = <CharTraceStep>[];
      final Set<String> seenDomainIds = <String>{};
      final List<CharacterDomain> detectedDomains = <CharacterDomain>[];
      int stepCounter = 0;

      for (final String grapheme in inputText.characters) {
        stepCounter++;
        final bool isPreservedSpace = grapheme == ' ' && preserveSpaces;
        final CharacterDomain? domain = isPreservedSpace
            ? null
            : PredefinedDomains.resolveDomain(
                grapheme,
                preserveSpaces: preserveSpaces,
              );

        if (domain != null && seenDomainIds.add(domain.id)) {
          detectedDomains.add(domain);
        }

        final String domainLabel;
        if (isPreservedSpace) {
          domainLabel = 'SPACE (Bypassed)';
        } else if (domain != null) {
          domainLabel = '${domain.shortName} (${domain.modulus})';
        } else {
          domainLabel = 'Unknown (Bypassed)';
        }

        bypassedSteps.add(
          CharTraceStep(
            stepIndex: stepCounter,
            inputChar: grapheme,
            domainLabel: domainLabel,
            originalIndex: domain?.indexOf(grapheme),
            formula: 'Bypassed (Invalid/Empty Keyword)',
            newIndex: null,
            outputChar: grapheme,
            isBypassed: true,
          ),
        );
      }

      return CipherProcessResult(
        outputText: inputText,
        traceSteps: List<CharTraceStep>.unmodifiable(bypassedSteps),
        detectedDomains: List<CharacterDomain>.unmodifiable(detectedDomains),
        validationMessage: emptyKeywordValidationMessage,
      );
    }

    if (inputText.isEmpty) {
      return const CipherProcessResult.empty();
    }

    final StringBuffer outputBuffer = StringBuffer();
    final List<CharTraceStep> traceSteps = <CharTraceStep>[];
    final Set<String> seenDomainIds = <String>{};
    final List<CharacterDomain> detectedDomains = <CharacterDomain>[];

    int stepCounter = 0;
    int keyStep = 0;

    for (final String grapheme in inputText.characters) {
      stepCounter++;

      // Rule: When preserveSpaces is ON and grapheme is space ' ', bypass shifting
      // and DO NOT increment keyStep.
      if (grapheme == ' ' && preserveSpaces) {
        outputBuffer.write(grapheme);
        traceSteps.add(
          CharTraceStep(
            stepIndex: stepCounter,
            inputChar: grapheme,
            domainLabel: 'SPACE (Bypassed)',
            originalIndex: null,
            formula: 'Preserved (Toggle ON)',
            newIndex: null,
            outputChar: grapheme,
            isBypassed: true,
          ),
        );
        continue;
      }

      final CharacterDomain? domain = PredefinedDomains.resolveDomain(
        grapheme,
        preserveSpaces: preserveSpaces,
      );

      // Unknown character outside all 10 domains: bypass shifting and DO NOT increment keyStep.
      if (domain == null) {
        outputBuffer.write(grapheme);
        traceSteps.add(
          CharTraceStep(
            stepIndex: stepCounter,
            inputChar: grapheme,
            domainLabel: 'Unknown (Bypassed)',
            originalIndex: null,
            formula: 'Bypassed (Unmapped)',
            newIndex: null,
            outputChar: grapheme,
            isBypassed: true,
          ),
        );
        continue;
      }

      if (seenDomainIds.add(domain.id)) {
        detectedDomains.add(domain);
      }

      final int p = domain.indexOf(grapheme)!;
      final int n = domain.modulus;
      final VigenereKeyToken keyToken = keyTokens[keyStep % keyTokens.length];
      final String keyChar = keyToken.grapheme;
      final int k = keyToken.keyIndex;

      final int shift = isEncrypt ? k : -k;
      final int c = positiveModulo(p, shift, n);
      final String transformedChar = domain.symbolAt(c);

      final String formula = isEncrypt
          ? '[$keyChar=$k] ($p + $k) mod $n = $c'
          : '[$keyChar=$k] ($p - $k) mod $n = $c';

      outputBuffer.write(transformedChar);
      traceSteps.add(
        CharTraceStep(
          stepIndex: stepCounter,
          inputChar: grapheme,
          domainLabel: '${domain.shortName} ($n)',
          originalIndex: p,
          formula: formula,
          newIndex: c,
          outputChar: transformedChar,
          isBypassed: false,
        ),
      );

      // Increment keyStep ONLY after a valid character transformation.
      keyStep++;
    }

    return CipherProcessResult(
      outputText: outputBuffer.toString(),
      traceSteps: List<CharTraceStep>.unmodifiable(traceSteps),
      detectedDomains: List<CharacterDomain>.unmodifiable(detectedDomains),
    );
  }

  @override
  List<Object?> get props => [id];
}
