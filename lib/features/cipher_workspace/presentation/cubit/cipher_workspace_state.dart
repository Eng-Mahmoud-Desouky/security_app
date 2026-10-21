import 'package:equatable/equatable.dart';
import '../../../../core/alphabets/character_domain.dart';
import '../../../../domain/ciphers/cipher_engine.dart';
import '../../../../domain/entities/brute_force_candidate.dart';
import '../../../../domain/entities/char_trace_step.dart';
import '../../../../domain/entities/cipher_process_result.dart';

/// Operation modes supported by the workspace.
enum CipherOperationMode {
  encrypt,
  decrypt,
  crack,
}

/// Output view tabs for switching between Result/Crack view and Paper-Trace table
/// without using nested unbounded TabBarViews.
enum WorkspaceOutputTab {
  resultOrCrack,
  paperTrace,
}

/// Immutable state for the Cipher Workspace screen.
class CipherWorkspaceState extends Equatable {
  final String inputText;
  final int key;
  final CipherOperationMode operationMode;
  final bool preserveSpaces;
  final CipherEngine activeEngine;
  final CipherProcessResult processResult;
  final List<BruteForceCandidate> bruteForceCandidates;
  final List<CharacterDomain> detectedDomains;
  final int maxDetectedModulus;
  final int? inspectedCrackKey;
  final WorkspaceOutputTab activeOutputTab;

  const CipherWorkspaceState({
    required this.inputText,
    required this.key,
    required this.operationMode,
    required this.preserveSpaces,
    required this.activeEngine,
    required this.processResult,
    required this.bruteForceCandidates,
    required this.detectedDomains,
    required this.maxDetectedModulus,
    this.inspectedCrackKey,
    this.activeOutputTab = WorkspaceOutputTab.resultOrCrack,
  });

  /// Returns the trace steps currently active for the Paper-Trace table.
  /// In Crack mode, returns the trace steps for [inspectedCrackKey] (or K=1 by default).
  List<CharTraceStep> get activeTraceSteps {
    if (operationMode == CipherOperationMode.crack) {
      if (bruteForceCandidates.isEmpty) return const [];
      final int targetKey = inspectedCrackKey ?? 1;
      for (final candidate in bruteForceCandidates) {
        if (candidate.key == targetKey) {
          return candidate.traceSteps;
        }
      }
      return bruteForceCandidates.first.traceSteps;
    }
    return processResult.traceSteps;
  }

  /// Returns the effective key currently being traced in the Paper-Trace table.
  int get effectiveTraceKey {
    if (operationMode == CipherOperationMode.crack) {
      return inspectedCrackKey ?? 1;
    }
    return key;
  }

  @override
  List<Object?> get props => [
        inputText,
        key,
        operationMode,
        preserveSpaces,
        activeEngine,
        processResult,
        bruteForceCandidates,
        detectedDomains,
        maxDetectedModulus,
        inspectedCrackKey,
        activeOutputTab,
      ];
}
