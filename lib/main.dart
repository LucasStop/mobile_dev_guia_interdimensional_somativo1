import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/character_list_provider.dart';
import 'screens/catalog_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

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
        ChangeNotifierProvider(create: (_) => FavoritesProvider(storage)),
        ChangeNotifierProvider(create: (_) => WatchedProvider(storage)),
      ],
      child: MaterialApp(
        title: 'Guia Interdimensional',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        // O aumento de fonte do sistema é respeitado, mas com teto: acima de
        // 1.6x o layout deixaria de caber (RF10).
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: AppTheme.clampTextScaler(context),
          ),
          child: child!,
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
