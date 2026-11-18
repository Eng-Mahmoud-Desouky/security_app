import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cipher_workspace_cubit.dart';
import '../cubit/cipher_workspace_state.dart';
import '../widgets/control_bar_widget.dart';
import '../widgets/input_card_widget.dart';
import '../widgets/output_section_widget.dart';

/// Main single-screen workspace for the Multi-Domain Caesar Cipher Engine.
class CipherWorkspacePage extends StatelessWidget {
  const CipherWorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: BlocBuilder<CipherWorkspaceCubit, CipherWorkspaceState>(
          buildWhen: (prev, curr) => prev.activeEngine != curr.activeEngine,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.activeEngine.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '10-Domain Grapheme-Safe Cryptography Engine',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<CipherWorkspaceCubit>().resetWorkspace();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workspace reset to defaults'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset Workspace',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<CipherWorkspaceCubit, CipherWorkspaceState>(
                    buildWhen: (prev, curr) =>
                        prev.cipherType != curr.cipherType,
                    builder: (context, state) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cipher Algorithm',
                                    style:
                                        theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SegmentedButton<CipherType>(
                                segments: const <ButtonSegment<CipherType>>[
                                  ButtonSegment<CipherType>(
                                    value: CipherType.caesar,
                                    label: Text('Caesar Cipher'),
                                    icon: Icon(Icons.dialpad_rounded),
                                  ),
                                  ButtonSegment<CipherType>(
                                    value: CipherType.vigenere,
                                    label: Text('Vigenère Cipher'),
                                    icon: Icon(Icons.vpn_key_rounded),
                                  ),
                                ],
                                selected: <CipherType>{state.cipherType},
                                onSelectionChanged:
                                    (Set<CipherType> selection) {
                                  context
                                      .read<CipherWorkspaceCubit>()
                                      .setCipherType(selection.first);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const InputCardWidget(),
                  const SizedBox(height: 12),
                  const ControlBarWidget(),
                  const SizedBox(height: 12),
                  const OutputSectionWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
