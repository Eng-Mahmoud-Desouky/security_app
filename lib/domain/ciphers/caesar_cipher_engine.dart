import 'dart:math' as math;
import 'package:characters/characters.dart';
import '../../core/alphabets/character_domain.dart';
import '../../core/alphabets/predefined_domains.dart';
import '../entities/brute_force_candidate.dart';
import '../entities/char_trace_step.dart';
import '../entities/cipher_process_result.dart';
import 'cipher_engine.dart';

/// Multi-Domain Caesar Cipher implementation following SRS Section 1-3.
class CaesarCipherEngine extends CipherEngine {
  static const int defaultFallbackModulus = 36;

  const CaesarCipherEngine();

  @override
  String get id => 'caesar_multi_domain';

  @override
  String get name => 'Multi-Domain Caesar Cipher';

  @override
  String get description =>
      'C = ((P + K) mod N_D + N_D) mod N_D  |  P = ((C - K) mod N_D + N_D) mod N_D';

  /// Positive mathematical modulo in Dart: ((p + shift) % n + n) % n
  int positiveModulo(int p, int shift, int n) {
    return ((p + shift) % n + n) % n;
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

  @override
  CipherProcessResult encrypt(
    String inputText, {
    required int key,
    required bool preserveSpaces,
  }) {
    return _process(
      inputText: inputText,
      key: key,
      isEncrypt: true,
      preserveSpaces: preserveSpaces,
    );
  }

  @override
  CipherProcessResult decrypt(
    String inputText, {
    required int key,
    required bool preserveSpaces,
  }) {
    return _process(
      inputText: inputText,
      key: key,
      isEncrypt: false,
      preserveSpaces: preserveSpaces,
    );
  }

  @override
  List<BruteForceCandidate> crack(
    String inputText, {
    required bool preserveSpaces,
  }) {
    if (inputText.isEmpty) return const [];

    final List<CharacterDomain> activeDomains = detectDomains(
      inputText,
      preserveSpaces: preserveSpaces,
    );
    final int maxBound = calculateMaxModulus(activeDomains);

    final List<BruteForceCandidate> candidates = <BruteForceCandidate>[];
    for (int k = 1; k < maxBound; k++) {
      final CipherProcessResult result = decrypt(
        inputText,
        key: k,
        preserveSpaces: preserveSpaces,
      );
      candidates.add(
        BruteForceCandidate(
          key: k,
          decryptedText: result.outputText,
          traceSteps: result.traceSteps,
        ),
      );
    }

    return List<BruteForceCandidate>.unmodifiable(candidates);
  }

  CipherProcessResult _process({
    required String inputText,
    required int key,
    required bool isEncrypt,
    required bool preserveSpaces,
  }) {
    if (inputText.isEmpty) {
      return const CipherProcessResult.empty();
    }

    final StringBuffer outputBuffer = StringBuffer();
    final List<CharTraceStep> traceSteps = <CharTraceStep>[];
    final Set<String> seenDomainIds = <String>{};
    final List<CharacterDomain> detectedDomains = <CharacterDomain>[];

    int stepCounter = 0;

    for (final String grapheme in inputText.characters) {
      stepCounter++;

      // Rule: When preserveSpaces is ON and grapheme is space ' ', bypass shifting.
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

      // Unknown character (e.g. newline or unsupported symbol outside the 10 domains)
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
      final int shift = isEncrypt ? key : -key;
      final int c = positiveModulo(p, shift, n);
      final String transformedChar = domain.symbolAt(c);

      final String formula = isEncrypt
          ? '($p + $key) mod $n = $c'
          : '($p - $key) mod $n = $c';

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
