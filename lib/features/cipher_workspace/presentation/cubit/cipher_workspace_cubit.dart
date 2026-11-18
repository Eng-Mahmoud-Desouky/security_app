import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/alphabets/character_domain.dart';
import '../../../../domain/ciphers/caesar_cipher_engine.dart';
import '../../../../domain/ciphers/cipher_engine.dart';
import '../../../../domain/ciphers/vigenere_cipher_engine.dart';
import '../../../../domain/entities/brute_force_candidate.dart';
import '../../../../domain/entities/cipher_process_result.dart';
import 'cipher_workspace_state.dart';

/// Reactive Cubit managing the Multi-Domain Caesar & Vigenère Cipher workspace.
class CipherWorkspaceCubit extends Cubit<CipherWorkspaceState> {
  static const CaesarCipherEngine _caesarEngine = CaesarCipherEngine();
  static const VigenereCipherEngine _vigenereEngine = VigenereCipherEngine();

  CipherWorkspaceCubit({CipherEngine? initialEngine})
      : super(
          _computeState(
            cipherType: initialEngine is VigenereCipherEngine
                ? CipherType.vigenere
                : CipherType.caesar,
            inputText: '',
            key: 3,
            vigenereKey: 'KEY',
            operationMode: CipherOperationMode.encrypt,
            preserveSpaces: true,
            activeEngine: initialEngine ?? _caesarEngine,
            inspectedCrackKey: null,
            activeOutputTab: WorkspaceOutputTab.resultOrCrack,
          ),
        );

  /// Switches between Caesar and Vigenère cipher engines.
  /// If switching to Vigenère while in Crack mode, automatically transitions to Encrypt.
  void setCipherType(CipherType cipherType) {
    final CipherEngine nextEngine =
        cipherType == CipherType.vigenere ? _vigenereEngine : _caesarEngine;
    final CipherOperationMode nextMode =
        cipherType == CipherType.vigenere &&
                state.operationMode == CipherOperationMode.crack
            ? CipherOperationMode.encrypt
            : state.operationMode;

    emit(
      _computeState(
        cipherType: cipherType,
        inputText: state.inputText,
        key: state.key,
        vigenereKey: state.vigenereKey,
        operationMode: nextMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: nextEngine,
        inspectedCrackKey:
            cipherType == CipherType.vigenere ? null : state.inspectedCrackKey,
        activeOutputTab: state.activeOutputTab,
      ),
    );
  }

  /// Updates the Vigenère keyword and immediately recalculates outputs and traces.
  void updateVigenereKey(String vigenereKey) {
    emit(
      _computeState(
        cipherType: state.cipherType,
        inputText: state.inputText,
        key: state.key,
        vigenereKey: vigenereKey,
        operationMode: state.operationMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: state.activeEngine,
        inspectedCrackKey: state.inspectedCrackKey,
        activeOutputTab: state.activeOutputTab,
      ),
    );
  }

  /// Updates the input text and immediately recalculates outputs and traces.
  void updateInputText(String text) {
    emit(
      _computeState(
        cipherType: state.cipherType,
        inputText: text,
        key: state.key,
        vigenereKey: state.vigenereKey,
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
        cipherType: state.cipherType,
        inputText: state.processResult.outputText,
        key: state.key,
        vigenereKey: state.vigenereKey,
        operationMode: nextMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: state.activeEngine,
        inspectedCrackKey: null,
        activeOutputTab: WorkspaceOutputTab.resultOrCrack,
      ),
    );
  }

  /// Updates the Caesar shift key K.
  void updateKey(int newKey) {
    emit(
      _computeState(
        cipherType: state.cipherType,
        inputText: state.inputText,
        key: newKey,
        vigenereKey: state.vigenereKey,
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
  /// Guards against `Crack` mode when `cipherType` is `CipherType.vigenere`.
  void setOperationMode(CipherOperationMode mode) {
    final CipherOperationMode safeMode =
        state.cipherType == CipherType.vigenere &&
                mode == CipherOperationMode.crack
            ? CipherOperationMode.encrypt
            : mode;

    emit(
      _computeState(
        cipherType: state.cipherType,
        inputText: state.inputText,
        key: state.key,
        vigenereKey: state.vigenereKey,
        operationMode: safeMode,
        preserveSpaces: state.preserveSpaces,
        activeEngine: state.activeEngine,
        inspectedCrackKey:
            safeMode == CipherOperationMode.crack ? 1 : null,
        activeOutputTab: state.activeOutputTab,
      ),
    );
  }

  /// Toggles `"Preserve Spaces & Unknowns"`.
  void togglePreserveSpaces(bool preserve) {
    emit(
      _computeState(
        cipherType: state.cipherType,
        inputText: state.inputText,
        key: state.key,
        vigenereKey: state.vigenereKey,
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
        cipherType: state.cipherType,
        inputText: state.inputText,
        key: state.key,
        vigenereKey: state.vigenereKey,
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
        cipherType: state.cipherType,
        inputText: state.inputText,
        key: state.key,
        vigenereKey: state.vigenereKey,
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
    final CipherType nextType = engine is VigenereCipherEngine
        ? CipherType.vigenere
        : CipherType.caesar;
    final CipherOperationMode nextMode =
        nextType == CipherType.vigenere &&
                state.operationMode == CipherOperationMode.crack
            ? CipherOperationMode.encrypt
            : state.operationMode;

    emit(
      _computeState(
        cipherType: nextType,
        inputText: state.inputText,
        key: state.key,
        vigenereKey: state.vigenereKey,
        operationMode: nextMode,
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
        cipherType: state.cipherType,
        inputText: '',
        key: 3,
        vigenereKey: 'KEY',
        operationMode: CipherOperationMode.encrypt,
        preserveSpaces: true,
        activeEngine: state.activeEngine,
        inspectedCrackKey: null,
        activeOutputTab: WorkspaceOutputTab.resultOrCrack,
      ),
    );
  }

  static CipherWorkspaceState _computeState({
    required CipherType cipherType,
    required String inputText,
    required int key,
    required String vigenereKey,
    required CipherOperationMode operationMode,
    required bool preserveSpaces,
    required CipherEngine activeEngine,
    required int? inspectedCrackKey,
    required WorkspaceOutputTab activeOutputTab,
  }) {
    final CipherOperationMode effectiveMode =
        cipherType == CipherType.vigenere &&
                operationMode == CipherOperationMode.crack
            ? CipherOperationMode.encrypt
            : operationMode;

    final List<CharacterDomain> detectedDomains = activeEngine.detectDomains(
      inputText,
      preserveSpaces: preserveSpaces,
    );
    final int maxModulus = activeEngine.calculateMaxModulus(detectedDomains);

    CipherProcessResult processResult;
    List<BruteForceCandidate> bruteForceCandidates = const [];
    int? resolvedInspectedKey = inspectedCrackKey;

    if (cipherType == CipherType.vigenere) {
      resolvedInspectedKey = null;
      switch (effectiveMode) {
        case CipherOperationMode.encrypt:
          processResult = _vigenereEngine.encryptWithKeyword(
            inputText,
            keyword: vigenereKey,
            preserveSpaces: preserveSpaces,
          );
          break;
        case CipherOperationMode.decrypt:
        case CipherOperationMode.crack:
          processResult = _vigenereEngine.decryptWithKeyword(
            inputText,
            keyword: vigenereKey,
            preserveSpaces: preserveSpaces,
          );
          break;
      }
    } else {
      switch (effectiveMode) {
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
    }

    return CipherWorkspaceState(
      cipherType: cipherType,
      inputText: inputText,
      key: key,
      vigenereKey: vigenereKey,
      operationMode: effectiveMode,
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
