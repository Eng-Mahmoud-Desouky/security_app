import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cipher_workspace_cubit.dart';
import '../cubit/cipher_workspace_state.dart';
import 'emoji_grid_sheet.dart';

/// Input Card containing the multiline RTL/LTR-aware TextField,
/// Copy/Paste/Clear actions, Controlled Emoji Grid trigger, and Active Domain Badges.
class InputCardWidget extends StatefulWidget {
  const InputCardWidget({super.key});

  @override
  State<InputCardWidget> createState() => _InputCardWidgetState();
}

class _InputCardWidgetState extends State<InputCardWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialText = context.read<CipherWorkspaceCubit>().state.inputText;
    _controller = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertEmojiAtCursor(String emoji) {
    final CipherWorkspaceCubit cubit = context.read<CipherWorkspaceCubit>();
    final String text = _controller.text;
    final TextSelection selection = _controller.selection;

    String newText;
    int newCursorOffset;

    if (selection.isValid &&
        selection.start >= 0 &&
        selection.end <= text.length) {
      newText = text.replaceRange(selection.start, selection.end, emoji);
      newCursorOffset = selection.start + emoji.length;
    } else {
      newText = '$text$emoji';
      newCursorOffset = newText.length;
    }

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
    cubit.updateInputText(newText);
  }

  Future<void> _handlePaste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final String? pasted = data?.text;
    if (pasted != null && pasted.isNotEmpty) {
      context.read<CipherWorkspaceCubit>().updateInputText(pasted);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pasted text from clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _handleCopy(String text) async {
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Input copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocListener<CipherWorkspaceCubit, CipherWorkspaceState>(
      listenWhen: (previous, current) =>
          previous.inputText != current.inputText,
      listener: (context, state) {
        if (_controller.text != state.inputText) {
          _controller.value = TextEditingValue(
            text: state.inputText,
            selection: TextSelection.collapsed(
              offset: state.inputText.length,
            ),
          );
        }
      },
      child: BlocBuilder<CipherWorkspaceCubit, CipherWorkspaceState>(
        builder: (context, state) {
          final int graphemeCount = state.inputText.characters.length;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.operationMode == CipherOperationMode.encrypt
                                ? 'Plaintext Input'
                                : 'Ciphertext Input',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$graphemeCount graphemes',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              EmojiGridSheet.show(
                                context,
                                onEmojiSelected: _insertEmojiAtCursor,
                              );
                            },
                            icon: const Icon(Icons.emoji_emotions_outlined),
                            tooltip: 'Insert Emoji (DOM_EMOJI 0..19)',
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: _handlePaste,
                            icon: const Icon(Icons.content_paste_rounded),
                            tooltip: 'Paste',
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: state.inputText.isEmpty
                                ? null
                                : () => _handleCopy(state.inputText),
                            icon: const Icon(Icons.copy_rounded),
                            tooltip: 'Copy Input',
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: state.inputText.isEmpty
                                ? null
                                : () => context
                                    .read<CipherWorkspaceCubit>()
                                    .clearInput(),
                            icon: const Icon(Icons.clear_rounded),
                            tooltip: 'Clear Input',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    minLines: 3,
                    maxLines: 5,
                    onChanged: (value) {
                      context
                          .read<CipherWorkspaceCubit>()
                          .updateInputText(value);
                    },
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Enter multilingual text, symbols, or pick emojis (e.g. Hello مرحبا ❤️🛡️)...',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.grid_view_rounded),
                        tooltip: 'Open Controlled Emoji Grid (0..19)',
                        onPressed: () {
                          EmojiGridSheet.show(
                            context,
                            onEmojiSelected: _insertEmojiAtCursor,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.radar_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Detected Domains:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: state.detectedDomains.isEmpty
                            ? Text(
                                'None (Fallback Max N = ${state.maxDetectedModulus})',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.outline,
                                ),
                              )
                            : Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: state.detectedDomains.map((domain) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      domain.badgeLabel,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: theme
                                            .colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
