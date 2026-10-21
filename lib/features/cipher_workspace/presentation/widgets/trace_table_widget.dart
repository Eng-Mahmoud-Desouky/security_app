import 'package:flutter/material.dart';
import '../../../../domain/entities/char_trace_step.dart';
import '../cubit/cipher_workspace_state.dart';

/// Mathematical Paper-Trace Inspector rendering every character's transformation:
/// `Char | Domain (N) | Index P | Formula | New Index C | Result`
class TraceTableWidget extends StatelessWidget {
  final List<CharTraceStep> traceSteps;
  final CipherOperationMode operationMode;
  final int effectiveKey;

  const TraceTableWidget({
    super.key,
    required this.traceSteps,
    required this.operationMode,
    required this.effectiveKey,
  });

  String _formatVisibleChar(String char) {
    if (char == ' ') return "' '";
    if (char == '\n') return r'\n';
    if (char == '\t') return r'\t';
    return char;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (traceSteps.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              Icons.functions_rounded,
              size: 36,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter text above to inspect the step-by-step mathematical paper trace.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (operationMode == CipherOperationMode.crack) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 18,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tracing Candidate Key K = $effectiveKey (Decryption Formula)',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll<Color>(
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
              ),
              columnSpacing: 20,
              horizontalMargin: 14,
              headingTextStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              columns: const <DataColumn>[
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Char')),
                DataColumn(label: Text('Domain (N)')),
                DataColumn(label: Text('Index P')),
                DataColumn(label: Text('Formula')),
                DataColumn(label: Text('New Index C')),
                DataColumn(label: Text('Result')),
              ],
              rows: traceSteps.map((step) {
                final TextStyle monoStyle =
                    (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                  fontFamily: 'monospace',
                );

                return DataRow(
                  color: step.isBypassed
                      ? WidgetStatePropertyAll<Color>(
                          theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.25,
                          ),
                        )
                      : null,
                  cells: <DataCell>[
                    DataCell(
                      Text(
                        '${step.stepIndex}',
                        style: monoStyle.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatVisibleChar(step.inputChar),
                          style: monoStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        step.domainLabel,
                        style: monoStyle.copyWith(
                          color: step.isBypassed
                              ? theme.colorScheme.outline
                              : theme.colorScheme.primary,
                          fontWeight: step.isBypassed
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        step.originalIndex?.toString() ?? '—',
                        style: monoStyle,
                      ),
                    ),
                    DataCell(
                      Text(
                        step.formula,
                        style: monoStyle.copyWith(
                          color: step.isBypassed
                              ? theme.colorScheme.outline
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        step.newIndex?.toString() ?? '—',
                        style: monoStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: step.isBypassed
                              ? theme.colorScheme.surfaceContainerHigh
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatVisibleChar(step.outputChar),
                          style: monoStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: step.isBypassed
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
