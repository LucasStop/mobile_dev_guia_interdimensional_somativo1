import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

/// Persistência local do app (RF06) e da sessão (RF07), sobre
/// `shared_preferences`.
///
/// Guarda o personagem inteiro, não só o id: as telas de Favoritos e de
/// Vistos abrem sem nenhuma requisição de rede, inclusive offline.
///
// ponytail: classe concreta, sem interface abstrata. Uma interface com uma
// implementação só é peso morto; quando a sincronização em nuvem entrar
// (bônus do RF06), extrai-se a interface a partir destes métodos.
class LocalStorage {
  static const _keyUser = 'session_user';
  static const _keyFavorites = 'favorites';
  static const _keyWatched = 'watched';
  static const _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;

  const LocalStorage(this._prefs);

  static Future<LocalStorage> open() async {
    return LocalStorage(await SharedPreferences.getInstance());
  }

  // --- Sessão (RF07) ---

  String? get sessionUser => _prefs.getString(_keyUser);

  Future<void> saveSession(String user) => _prefs.setString(_keyUser, user);

  Future<void> clearSession() => _prefs.remove(_keyUser);

  // --- Preferência de tema ---

  /// Guardado como o nome do `ThemeMode` (`system`, `light`, `dark`).
  String? get themeMode => _prefs.getString(_keyThemeMode);

  Future<void> saveThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);

  // --- Listas de personagens (RF06) ---

  List<Character> readFavorites() => _readList(_keyFavorites);

  Future<void> writeFavorites(List<Character> characters) =>
      _writeList(_keyFavorites, characters);

  List<Character> readWatched() => _readList(_keyWatched);

  Future<void> writeWatched(List<Character> characters) =>
      _writeList(_keyWatched, characters);

  List<Character> _readList(String key) {
    final raw = _prefs.getStringList(key);
    if (raw == null) return [];

    final characters = <Character>[];
    for (final item in raw) {
      try {
        characters.add(
          Character.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } catch (_) {
        // Entrada corrompida ou de uma versão antiga do modelo: descarta esse
        // item em vez de derrubar a lista inteira no boot do app.
      }
    }
    return characters;
  }

  Future<void> _writeList(String key, List<Character> characters) {
    return _prefs.setStringList(
      key,
      characters.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }
}
