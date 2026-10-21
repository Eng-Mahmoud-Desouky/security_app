import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/alphabets/character_domain.dart';
import '../../../../domain/ciphers/caesar_cipher_engine.dart';
import '../../../../domain/ciphers/cipher_engine.dart';
import '../../../../domain/entities/brute_force_candidate.dart';
import '../../../../domain/entities/cipher_process_result.dart';
import 'cipher_workspace_state.dart';

/// Reactive Cubit managing the Multi-Domain Caesar Cipher workspace.
class CipherWorkspaceCubit extends Cubit<CipherWorkspaceState> {
  CipherWorkspaceCubit({CipherEngine? initialEngine})
      : super(
          _computeState(
            inputText: '',
            key: 3,
            operationMode: CipherOperationMode.encrypt,
            preserveSpaces: true,
            activeEngine: initialEngine ?? const CaesarCipherEngine(),
            inspectedCrackKey: null,
            activeOutputTab: WorkspaceOutputTab.resultOrCrack,
          ),
        );

  /// Updates the input text and immediately recalculates outputs and traces.
  void updateInputText(String text) {
    emit(
      _computeState(
        inputText: text,
        key: state.key,
        operationMode: state.operationMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: state.activeEngine,
        inspectedCrackKey: state.inspectedCrackKey,
        activeOutputTab: state.activeOutputTab,
      ),
    );
  }

  /// Clears the input text.
  void clearInput() {
    updateInputText('');
  }

  /// Replaces input text with the current encryption/decryption output for quick round-trip testing.
  void useOutputAsInput() {
    if (state.processResult.outputText.isEmpty) return;
    final CipherOperationMode nextMode =
        state.operationMode == CipherOperationMode.encrypt
            ? CipherOperationMode.decrypt
            : CipherOperationMode.encrypt;

    emit(
      _computeState(
        inputText: state.processResult.outputText,
        key: state.key,
        operationMode: nextMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: state.activeEngine,
        inspectedCrackKey: null,
        activeOutputTab: WorkspaceOutputTab.resultOrCrack,
      ),
    );
  }

  /// Updates the shift key K.
  void updateKey(int newKey) {
    emit(
      _computeState(
        inputText: state.inputText,
        key: newKey,
        operationMode: state.operationMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: state.activeEngine,
        inspectedCrackKey: state.inspectedCrackKey,
        activeOutputTab: state.activeOutputTab,
      ),
    );
  }

  /// Increments the shift key K by 1.
  void incrementKey() => updateKey(state.key + 1);

  /// Decrements the shift key K by 1.
  void decrementKey() => updateKey(state.key - 1);

  /// Switches the operation mode (`Encrypt`, `Decrypt`, `Crack`).
  void setOperationMode(CipherOperationMode mode) {
    emit(
      _computeState(
        inputText: state.inputText,
        key: state.key,
        operationMode: mode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: state.activeEngine,
        inspectedCrackKey: mode == CipherOperationMode.crack ? 1 : null,
        activeOutputTab: state.activeOutputTab,
      ),
    );
  }

  /// Toggles `"Preserve Spaces & Unknowns"`.
  void togglePreserveSpaces(bool preserve) {
    emit(
      _computeState(
        inputText: state.inputText,
        key: state.key,
        operationMode: state.operationMode,
        preserveSpaces: preserve,
        activeEngine: state.activeEngine,
        inspectedCrackKey: state.inspectedCrackKey,
        activeOutputTab: state.activeOutputTab,
      ),
    );
  }

  /// Switches between the Result/Crack view and the Paper-Trace table.
  void setOutputTab(WorkspaceOutputTab tab) {
    emit(
      _computeState(
        inputText: state.inputText,
        key: state.key,
        operationMode: state.operationMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: state.activeEngine,
        inspectedCrackKey: state.inspectedCrackKey,
        activeOutputTab: tab,
      ),
    );
  }

  /// Selects a specific Brute-Force candidate key K to inspect in the Paper-Trace table
  /// and automatically switches the output tab to [WorkspaceOutputTab.paperTrace].
  void inspectCrackCandidate(int candidateKey) {
    emit(
      _computeState(
        inputText: state.inputText,
        key: state.key,
        operationMode: state.operationMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: state.activeEngine,
        inspectedCrackKey: candidateKey,
        activeOutputTab: WorkspaceOutputTab.paperTrace,
      ),
    );
  }

  /// Swaps the active cipher strategy engine (for future weekly cipher additions).
  void selectCipherEngine(CipherEngine engine) {
    emit(
      _computeState(
        inputText: state.inputText,
        key: state.key,
        operationMode: state.operationMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: engine,
        inspectedCrackKey: null,
        activeOutputTab: state.activeOutputTab,
      ),
    );
  }

  /// Resets the entire workspace to its clean initial state.
  void resetWorkspace() {
    emit(
      _computeState(
        inputText: '',
        key: 3,
        operationMode: CipherOperationMode.encrypt,
        preserveSpaces: true,
        activeEngine: state.activeEngine,
        inspectedCrackKey: null,
        activeOutputTab: WorkspaceOutputTab.resultOrCrack,
      ),
    );
  }

  static CipherWorkspaceState _computeState({
    required String inputText,
    required int key,
    required CipherOperationMode operationMode,
    required bool preserveSpaces,
    required CipherEngine activeEngine,
    required int? inspectedCrackKey,
    required WorkspaceOutputTab activeOutputTab,
  }) {
    final List<CharacterDomain> detectedDomains = activeEngine.detectDomains(
      inputText,
      preserveSpaces: preserveSpaces,
    );
    final int maxModulus = activeEngine.calculateMaxModulus(detectedDomains);

    CipherProcessResult processResult;
    List<BruteForceCandidate> bruteForceCandidates = const [];
    int? resolvedInspectedKey = inspectedCrackKey;

    switch (operationMode) {
      case CipherOperationMode.encrypt:
        processResult = activeEngine.encrypt(
          inputText,
          key: key,
          preserveSpaces: preserveSpaces,
        );
        break;
      case CipherOperationMode.decrypt:
        processResult = activeEngine.decrypt(
          inputText,
          key: key,
          preserveSpaces: preserveSpaces,
        );
        break;
      case CipherOperationMode.crack:
        bruteForceCandidates = activeEngine.crack(
          inputText,
          preserveSpaces: preserveSpaces,
        );
        if (resolvedInspectedKey == null ||
            resolvedInspectedKey < 1 ||
            resolvedInspectedKey >= maxModulus) {
          resolvedInspectedKey = 1;
        }
        processResult = activeEngine.decrypt(
          inputText,
          key: resolvedInspectedKey,
          preserveSpaces: preserveSpaces,
        );
        break;
    }

    return CipherWorkspaceState(
      inputText: inputText,
      key: key,
      operationMode: operationMode,
      preserveSpaces: preserveSpaces,
      activeEngine: activeEngine,
      processResult: processResult,
      bruteForceCandidates: bruteForceCandidates,
      detectedDomains: detectedDomains,
      maxDetectedModulus: maxModulus,
      inspectedCrackKey: resolvedInspectedKey,
      activeOutputTab: activeOutputTab,
    );
  }
}
