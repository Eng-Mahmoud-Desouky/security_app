import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/ciphers/vigenere_cipher_engine.dart';
import '../cubit/cipher_workspace_cubit.dart';
import '../cubit/cipher_workspace_state.dart';
import 'emoji_grid_sheet.dart';

/// Control Bar providing the Segmented Operation Selector (`Encrypt | Decrypt | Crack`),
/// Integer Key Input (Caesar) or Keyword Input with Emoji Picker (Vigenère),
/// and `"Preserve Spaces & Unknowns"` toggle switch.
class ControlBarWidget extends StatefulWidget {
  const ControlBarWidget({super.key});

  @override
  State<ControlBarWidget> createState() => _ControlBarWidgetState();
}

class _ControlBarWidgetState extends State<ControlBarWidget> {
  static const VigenereCipherEngine _vigenereEngine = VigenereCipherEngine();

  late final TextEditingController _keyController;
  late final TextEditingController _vigenereKeyController;

  @override
  void initState() {
    super.initState();
    final CipherWorkspaceState initialState =
        context.read<CipherWorkspaceCubit>().state;
    _keyController = TextEditingController(text: initialState.key.toString());
    _vigenereKeyController = TextEditingController(
      text: initialState.vigenereKey,
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    _vigenereKeyController.dispose();
    super.dispose();
  }

  void _insertEmojiIntoKeyword(String emoji) {
    final CipherWorkspaceCubit cubit = context.read<CipherWorkspaceCubit>();
    final String text = _vigenereKeyController.text;
    final TextSelection selection = _vigenereKeyController.selection;

    final String newText;
    final int newCursorOffset;

    if (selection.isValid &&
        selection.start >= 0 &&
        selection.end <= text.length) {
      newText = text.replaceRange(selection.start, selection.end, emoji);
      newCursorOffset = selection.start + emoji.length;
    } else {
      newText = '$text$emoji';
      newCursorOffset = newText.length;
    }

    _vigenereKeyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
    cubit.updateVigenereKey(newText);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocListener<CipherWorkspaceCubit, CipherWorkspaceState>(
      listenWhen: (previous, current) =>
          previous.key != current.key ||
          previous.vigenereKey != current.vigenereKey,
      listener: (context, state) {
        final String keyStr = state.key.toString();
        if (_keyController.text != keyStr && _keyController.text != '-') {
          _keyController.value = TextEditingValue(
            text: keyStr,
            selection: TextSelection.collapsed(offset: keyStr.length),
          );
        }

        if (_vigenereKeyController.text != state.vigenereKey) {
          _vigenereKeyController.value = TextEditingValue(
            text: state.vigenereKey,
            selection: TextSelection.collapsed(
              offset: state.vigenereKey.length,
            ),
          );
        }
      },
      child: BlocBuilder<CipherWorkspaceCubit, CipherWorkspaceState>(
        builder: (context, state) {
          final CipherWorkspaceCubit cubit =
              context.read<CipherWorkspaceCubit>();
          final bool isVigenere = state.cipherType == CipherType.vigenere;
          final bool isCrackMode =
              !isVigenere && state.operationMode == CipherOperationMode.crack;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<CipherOperationMode>(
                    segments: <ButtonSegment<CipherOperationMode>>[
                      const ButtonSegment<CipherOperationMode>(
                        value: CipherOperationMode.encrypt,
                        label: Text('Encrypt'),
                        icon: Icon(Icons.lock_outline_rounded),
                      ),
                      const ButtonSegment<CipherOperationMode>(
                        value: CipherOperationMode.decrypt,
                        label: Text('Decrypt'),
                        icon: Icon(Icons.lock_open_rounded),
                      ),
                      ButtonSegment<CipherOperationMode>(
                        value: CipherOperationMode.crack,
                        label: const Text('Crack (Brute-Force)'),
                        icon: const Icon(Icons.bolt_rounded),
                        enabled: !isVigenere,
                      ),
                    ],
                    selected: <CipherOperationMode>{state.operationMode},
                    onSelectionChanged:
                        (Set<CipherOperationMode> newSelection) {
                      cubit.setOperationMode(newSelection.first);
                    },
                  ),
                  const SizedBox(height: 14),
                  if (isVigenere) ...[
                    _buildVigenereKeywordControls(
                      context,
                      theme: theme,
                      state: state,
                      cubit: cubit,
                    ),
                  ] else if (!isCrackMode) ...[
                    _buildCaesarKeyStepper(
                      theme: theme,
                      cubit: cubit,
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer.withValues(
                          alpha: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_fix_high_rounded,
                            size: 20,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Smart Brute-Force Bound: M = max(N_detected) = ${state.maxDetectedModulus} '
                              '• Testing Keys K ∈ [1 .. ${state.maxDetectedModulus - 1}]',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 22),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'Preserve Spaces & Unknowns',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      state.preserveSpaces
                          ? "ON: Space (' ') & unknown chars bypass shifting unchanged"
                          : "OFF: Space (' ') routes to DOM_SYM (N=32) at Index 0",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: state.preserveSpaces,
                    onChanged: cubit.togglePreserveSpaces,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaesarKeyStepper({
    required ThemeData theme,
    required CipherWorkspaceCubit cubit,
  }) {
    return Row(
      children: [
        Icon(
          Icons.vpn_key_outlined,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shift Key (K)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Per-domain positive modulo shift',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: cubit.decrementKey,
          icon: const Icon(Icons.remove_rounded),
          tooltip: 'Decrement Key (K - 1)',
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 78,
          child: TextField(
            controller: _keyController,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(r'^-?\d*'),
              ),
            ],
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              final int? parsed = int.tryParse(value);
              if (parsed != null) {
                cubit.updateKey(parsed);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: cubit.incrementKey,
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Increment Key (K + 1)',
        ),
      ],
    );
  }

  Widget _buildVigenereKeywordControls(
    BuildContext context, {
    required ThemeData theme,
    required CipherWorkspaceState state,
    required CipherWorkspaceCubit cubit,
  }) {
    final List<VigenereKeyToken> parsedTokens = _vigenereEngine.parseKeyword(
      state.vigenereKey,
      preserveSpaces: state.preserveSpaces,
    );
    final bool hasEmptyValidKey = parsedTokens.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.vpn_key_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Polyalphabetic Keyword',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Supports multi-domain characters & controlled emojis (case/domain of input preserved)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _vigenereKeyController,
          onChanged: cubit.updateVigenereKey,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Enter keyword (e.g. KEY, مفتاح, 🔥🚀)...',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLowest,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  tooltip: 'Pick Emoji for Keyword (DOM_EMOJI 0..19)',
                  onPressed: () {
                    EmojiGridSheet.show(
                      context,
                      onEmojiSelected: _insertEmojiIntoKeyword,
                    );
                  },
                ),
                if (state.vigenereKey.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    tooltip: 'Clear Keyword',
                    onPressed: () {
                      _vigenereKeyController.clear();
                      cubit.updateVigenereKey('');
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (hasEmptyValidKey)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    VigenereCipherEngine.emptyKeywordValidationMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Key Stream:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              ...parsedTokens.map(
                (token) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '[${token.grapheme}=${token.keyIndex}]',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
