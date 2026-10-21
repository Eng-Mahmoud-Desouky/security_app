import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cipher_workspace_cubit.dart';
import '../cubit/cipher_workspace_state.dart';

/// Control Bar providing the Segmented Operation Selector (`Encrypt | Decrypt | Crack`),
/// Integer Key Input with `+` / `-` stepper buttons (disabled/hidden in Crack mode),
/// and `"Preserve Spaces & Unknowns"` toggle switch.
class ControlBarWidget extends StatefulWidget {
  const ControlBarWidget({super.key});

  @override
  State<ControlBarWidget> createState() => _ControlBarWidgetState();
}

class _ControlBarWidgetState extends State<ControlBarWidget> {
  late final TextEditingController _keyController;

  @override
  void initState() {
    super.initState();
    final int initialKey = context.read<CipherWorkspaceCubit>().state.key;
    _keyController = TextEditingController(text: initialKey.toString());
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocListener<CipherWorkspaceCubit, CipherWorkspaceState>(
      listenWhen: (previous, current) => previous.key != current.key,
      listener: (context, state) {
        final String keyStr = state.key.toString();
        if (_keyController.text != keyStr && _keyController.text != '-') {
          _keyController.value = TextEditingValue(
            text: keyStr,
            selection: TextSelection.collapsed(offset: keyStr.length),
          );
        }
      },
      child: BlocBuilder<CipherWorkspaceCubit, CipherWorkspaceState>(
        builder: (context, state) {
          final CipherWorkspaceCubit cubit =
              context.read<CipherWorkspaceCubit>();
          final bool isCrackMode =
              state.operationMode == CipherOperationMode.crack;

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
                    segments: const <ButtonSegment<CipherOperationMode>>[
                      ButtonSegment<CipherOperationMode>(
                        value: CipherOperationMode.encrypt,
                        label: Text('Encrypt'),
                        icon: Icon(Icons.lock_outline_rounded),
                      ),
                      ButtonSegment<CipherOperationMode>(
                        value: CipherOperationMode.decrypt,
                        label: Text('Decrypt'),
                        icon: Icon(Icons.lock_open_rounded),
                      ),
                      ButtonSegment<CipherOperationMode>(
                        value: CipherOperationMode.crack,
                        label: Text('Crack (Brute-Force)'),
                        icon: Icon(Icons.bolt_rounded),
                      ),
                    ],
                    selected: <CipherOperationMode>{state.operationMode},
                    onSelectionChanged:
                        (Set<CipherOperationMode> newSelection) {
                      cubit.setOperationMode(newSelection.first);
                    },
                  ),
                  const SizedBox(height: 14),
                  if (!isCrackMode) ...[
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
}
