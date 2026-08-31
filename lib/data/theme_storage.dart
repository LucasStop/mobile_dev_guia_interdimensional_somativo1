import 'package:shared_preferences/shared_preferences.dart';

/// Preferência de tema, sobre `shared_preferences`.
///
/// Sessão e listas de personagens migraram para o Supabase (autenticação
/// real e persistência em nuvem, bônus do RF06/RF07) — tema continua local
/// de propósito, não é dado de usuário e não precisa de sincronização.
///
/// Nome não é `LocalStorage` de propósito: `supabase_flutter` já exporta uma
/// classe com esse nome internamente, e o conflito quebra a resolução de
/// import.
class ThemeStorage {
  static const _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;

  const ThemeStorage(this._prefs);

  static Future<ThemeStorage> open() async {
    return ThemeStorage(await SharedPreferences.getInstance());
  }

  /// Guardado como o nome do `ThemeMode` (`system`, `light`, `dark`).
  String? get themeMode => _prefs.getString(_keyThemeMode);

  Future<void> saveThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);
}
