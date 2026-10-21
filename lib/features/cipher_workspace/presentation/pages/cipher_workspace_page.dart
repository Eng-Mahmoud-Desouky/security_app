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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputCardWidget(),
                  SizedBox(height: 12),
                  ControlBarWidget(),
                  SizedBox(height: 12),
                  OutputSectionWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
