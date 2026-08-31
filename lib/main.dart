import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'data/auth_repository.dart';
import 'data/character_list_repository.dart';
import 'data/theme_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/character_list_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/catalog_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );
  final storage = await ThemeStorage.open();
  runApp(GuiaInterdimensionalApp(storage: storage));
}

class GuiaInterdimensionalApp extends StatelessWidget {
  final ThemeStorage storage;

  const GuiaInterdimensionalApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(SupabaseAuthRepository(client)),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(
            SupabaseCharacterListRepository(client, 'favorite'),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchedProvider(
            SupabaseCharacterListRepository(client, 'watched'),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Guia Interdimensional',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.mode,
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
      ),
    );
  }
}

/// RF07 — navegação condicional: o catálogo só existe para quem tem sessão
/// aberta. Observa o `AuthProvider`, então login e logout trocam a tela sem
/// nenhuma chamada manual ao `Navigator`.
///
/// Também é quem dispara `load()` nas listas assim que a sessão abre e
/// `clear()` assim que ela fecha — as listas moraram na nuvem agora, então
/// precisam ser buscadas de novo a cada login, e esvaziadas no logout pra não
/// vazar dado de uma conta pra outra na mesma instância do app.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  bool? _wasLoggedIn;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.select<AuthProvider, bool>((a) => a.isLoggedIn);

    if (isLoggedIn != _wasLoggedIn) {
      _wasLoggedIn = isLoggedIn;
      // Adiado pro fim do frame: build não pode disparar notifyListeners.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (isLoggedIn) {
          context.read<FavoritesProvider>().load();
          context.read<WatchedProvider>().load();
        } else {
          context.read<FavoritesProvider>().clear();
          context.read<WatchedProvider>().clear();
        }
      });
    }

    return isLoggedIn ? const CatalogScreen() : const LoginScreen();
  }
}
