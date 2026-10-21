import 'package:equatable/equatable.dart';
import '../../core/alphabets/character_domain.dart';
import 'char_trace_step.dart';

/// Encapsulates the output of a single encryption or decryption operation,
/// including the transformed text, per-grapheme paper trace, and active domains.
class CipherProcessResult extends Equatable {
  final String outputText;
  final List<CharTraceStep> traceSteps;
  final List<CharacterDomain> detectedDomains;

  const CipherProcessResult({
    required this.outputText,
    required this.traceSteps,
    required this.detectedDomains,
  });

  const CipherProcessResult.empty()
      : outputText = '',
        traceSteps = const [],
        detectedDomains = const [];

  @override
  List<Object?> get props => [outputText, traceSteps, detectedDomains];
}
