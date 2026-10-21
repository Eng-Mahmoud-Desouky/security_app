import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/brute_force_candidate.dart';

/// Displays the Smart Brute-Force candidate list for K in [1 .. max(N_detected) - 1].
/// Uses `shrinkWrap: true` and `NeverScrollableScrollPhysics()` so it embeds safely
/// inside the parent `SingleChildScrollView` without unbounded height exceptions.
class BruteForceListWidget extends StatelessWidget {
  final List<BruteForceCandidate> candidates;
  final int maxModulus;
  final int? inspectedCrackKey;
  final ValueChanged<int> onTraceCandidate;

  const BruteForceListWidget({
    super.key,
    required this.candidates,
    required this.maxModulus,
    required this.inspectedCrackKey,
    required this.onTraceCandidate,
  });

  Future<void> _copyCandidate(BuildContext context, BruteForceCandidate c) async {
    await Clipboard.setData(ClipboardData(text: c.decryptedText));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied candidate K = ${c.key} to clipboard'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (candidates.isEmpty) {
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
              Icons.lock_clock_outlined,
              size: 36,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter ciphertext above to generate Smart Brute-Force candidates '
              '(K = 1 .. ${maxModulus - 1}).',
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Generated ${candidates.length} candidates (K = 1 .. ${maxModulus - 1}). '
                  'Tap "Trace K" to verify any candidate in the Paper-Trace Table.',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: candidates.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final BruteForceCandidate candidate = candidates[index];
            final bool isInspected = inspectedCrackKey == candidate.key;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isInspected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                    : theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isInspected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: isInspected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'K = ${candidate.key}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => onTraceCandidate(candidate.key),
                        icon: const Icon(Icons.table_chart_outlined, size: 16),
                        label: Text('Trace K=${candidate.key}'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _copyCandidate(context, candidate),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        tooltip: 'Copy Candidate K = ${candidate.key}',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    candidate.decryptedText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
