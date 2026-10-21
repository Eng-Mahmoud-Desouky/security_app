import 'package:equatable/equatable.dart';

/// Represents a single per-grapheme mathematical transformation row for the
/// Paper-Trace Inspector (`Char | Domain (N) | Index P | Formula | New Index C | Result`).
class CharTraceStep extends Equatable {
  final int stepIndex;
  final String inputChar;
  final String domainLabel;
  final int? originalIndex;
  final String formula;
  final int? newIndex;
  final String outputChar;
  final bool isBypassed;

  const CharTraceStep({
    required this.stepIndex,
    required this.inputChar,
    required this.domainLabel,
    required this.originalIndex,
    required this.formula,
    required this.newIndex,
    required this.outputChar,
    this.isBypassed = false,
  });

  @override
  List<Object?> get props => [
        stepIndex,
        inputChar,
        domainLabel,
        originalIndex,
        formula,
        newIndex,
        outputChar,
        isBypassed,
      ];
}
