import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local_storage.dart';
import 'providers/auth_provider.dart';
import 'screens/catalog_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorage.open();
  runApp(GuiaInterdimensionalApp(storage: storage));
}

class GuiaInterdimensionalApp extends StatelessWidget {
  final LocalStorage storage;

  const GuiaInterdimensionalApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
      ],
      child: MaterialApp(
        title: 'Guia Interdimensional',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B5CC)),
        ),
        home: const _SessionGate(),
      ),
    );
  }
}

/// RF07 — navegação condicional: o catálogo só existe para quem tem sessão
/// aberta. Observa o `AuthProvider`, então login e logout trocam a tela sem
/// nenhuma chamada manual ao `Navigator`.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.select<AuthProvider, bool>((a) => a.isLoggedIn);
    return isLoggedIn ? const CatalogScreen() : const LoginScreen();
  }
}
