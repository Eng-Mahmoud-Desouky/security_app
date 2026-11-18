import 'package:equatable/equatable.dart';
import '../../core/alphabets/character_domain.dart';
import 'char_trace_step.dart';

/// Encapsulates the output of a single encryption or decryption operation,
/// including the transformed text, per-grapheme paper trace, active domains,
/// and optional validation warning message.
class CipherProcessResult extends Equatable {
  final String outputText;
  final List<CharTraceStep> traceSteps;
  final List<CharacterDomain> detectedDomains;
  final String? validationMessage;

  const CipherProcessResult({
    required this.outputText,
    required this.traceSteps,
    required this.detectedDomains,
    this.validationMessage,
  });

  const CipherProcessResult.empty()
      : outputText = '',
        traceSteps = const [],
        detectedDomains = const [],
        validationMessage = null;

  @override
  List<Object?> get props => [
        outputText,
        traceSteps,
        detectedDomains,
        validationMessage,
      ];
}
