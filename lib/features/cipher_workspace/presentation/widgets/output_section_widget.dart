import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cipher_workspace_cubit.dart';
import '../cubit/cipher_workspace_state.dart';
import 'brute_force_list_widget.dart';
import 'trace_table_widget.dart';

/// Output Section switching cleanly between the Output/Crack View and the
/// Mathematical Paper-Trace Data Table without nested vertical scroll viewports.
class OutputSectionWidget extends StatelessWidget {
  const OutputSectionWidget({super.key});

  Future<void> _copyOutput(BuildContext context, String output) async {
    if (output.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: output));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Output copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocBuilder<CipherWorkspaceCubit, CipherWorkspaceState>(
      builder: (context, state) {
        final CipherWorkspaceCubit cubit = context.read<CipherWorkspaceCubit>();
        final bool isCrackMode =
            state.operationMode == CipherOperationMode.crack;
        final int stepCount = state.activeTraceSteps.length;

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
                SegmentedButton<WorkspaceOutputTab>(
                  segments: <ButtonSegment<WorkspaceOutputTab>>[
                    ButtonSegment<WorkspaceOutputTab>(
                      value: WorkspaceOutputTab.resultOrCrack,
                      icon: Icon(
                        isCrackMode
                            ? Icons.format_list_numbered_rounded
                            : Icons.output_rounded,
                      ),
                      label: Text(
                        isCrackMode
                            ? 'Crack Candidates (${state.bruteForceCandidates.length})'
                            : (state.operationMode ==
                                    CipherOperationMode.encrypt
                                ? 'Encrypted Output'
                                : 'Decrypted Output'),
                      ),
                    ),
                    ButtonSegment<WorkspaceOutputTab>(
                      value: WorkspaceOutputTab.paperTrace,
                      icon: const Icon(Icons.table_chart_outlined),
                      label: Text('Paper-Trace Table ($stepCount)'),
                    ),
                  ],
                  selected: <WorkspaceOutputTab>{state.activeOutputTab},
                  onSelectionChanged: (Set<WorkspaceOutputTab> selection) {
                    cubit.setOutputTab(selection.first);
                  },
                ),
                const SizedBox(height: 14),
                if (state.activeOutputTab ==
                    WorkspaceOutputTab.resultOrCrack) ...[
                  if (isCrackMode)
                    BruteForceListWidget(
                      candidates: state.bruteForceCandidates,
                      maxModulus: state.maxDetectedModulus,
                      inspectedCrackKey: state.inspectedCrackKey,
                      onTraceCandidate: cubit.inspectCrackCandidate,
                    )
                  else
                    _SingleResultView(
                      outputText: state.processResult.outputText,
                      cipherType: state.cipherType,
                      operationMode: state.operationMode,
                      keyUsed: state.key,
                      vigenereKey: state.vigenereKey,
                      validationMessage: state.processResult.validationMessage,
                      onCopy: () =>
                          _copyOutput(context, state.processResult.outputText),
                      onUseAsInput: cubit.useOutputAsInput,
                    ),
                ] else ...[
                  TraceTableWidget(
                    traceSteps: state.activeTraceSteps,
                    operationMode: state.operationMode,
                    effectiveKey: state.effectiveTraceKey,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SingleResultView extends StatelessWidget {
  final String outputText;
  final CipherType cipherType;
  final CipherOperationMode operationMode;
  final int keyUsed;
  final String vigenereKey;
  final String? validationMessage;
  final VoidCallback onCopy;
  final VoidCallback onUseAsInput;

  const _SingleResultView({
    required this.outputText,
    required this.cipherType,
    required this.operationMode,
    required this.keyUsed,
    required this.vigenereKey,
    required this.validationMessage,
    required this.onCopy,
    required this.onUseAsInput,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasOutput = outputText.isNotEmpty;
    final String keyDescription = cipherType == CipherType.vigenere
        ? 'Keyword = "$vigenereKey"'
        : 'K = $keyUsed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (validationMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 10),
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
                    validationMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              operationMode == CipherOperationMode.encrypt
                  ? 'Ciphertext Result ($keyDescription)'
                  : 'Plaintext Result ($keyDescription)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: hasOutput ? onUseAsInput : null,
                  icon: const Icon(Icons.swap_vert_rounded, size: 18),
                  label: const Text('Use as Input'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: hasOutput ? onCopy : null,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: hasOutput
              ? SelectableText(
                  outputText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                )
              : Text(
                  'Transformed result will appear here in real time...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),
      ],
    );
  }
}
