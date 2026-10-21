import 'package:equatable/equatable.dart';
import 'char_trace_step.dart';

/// Represents a single candidate decryption generated during Smart Brute-Force (Crack).
class BruteForceCandidate extends Equatable {
  final int key;
  final String decryptedText;
  final List<CharTraceStep> traceSteps;

  const BruteForceCandidate({
    required this.key,
    required this.decryptedText,
    required this.traceSteps,
  });

  @override
  List<Object?> get props => [key, decryptedText, traceSteps];
}
