import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/cipher_workspace/presentation/cubit/cipher_workspace_cubit.dart';
import 'features/cipher_workspace/presentation/pages/cipher_workspace_page.dart';

void main() {
  runApp(const MultiDomainCipherApp());
}

class MultiDomainCipherApp extends StatelessWidget {
  const MultiDomainCipherApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color seedColor = Color(0xFF1E40AF);

    return BlocProvider<CipherWorkspaceCubit>(
      create: (_) => CipherWorkspaceCubit(),
      child: MaterialApp(
        title: 'Multi-Domain Caesar Cipher',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          ),
        ),
        home: const CipherWorkspacePage(),
      ),
    );
  }
}
