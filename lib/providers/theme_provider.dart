import 'package:flutter/material.dart';

import '../data/local_storage.dart';

/// Preferência de tema, persistida junto com o resto dos dados do app.
///
/// O padrão é seguir o sistema; o alternador da barra superior grava uma
/// escolha explícita, que sobrevive ao fechamento do app.
class ThemeProvider extends ChangeNotifier {
  final LocalStorage _storage;
  ThemeMode _mode;

  ThemeProvider(this._storage) : _mode = _parse(_storage.themeMode);

  ThemeMode get mode => _mode;

  /// O que o alternador deve mostrar agora, resolvendo `system` contra o
  /// brilho real da tela.
  bool isDark(BuildContext context) => switch (_mode) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system =>
          MediaQuery.platformBrightnessOf(context) == Brightness.dark,
      };

  /// Alterna entre claro e escuro. Sair de `system` exige saber para onde ir,
  /// por isso recebe o estado visível no momento do toque.
  Future<void> toggle(BuildContext context) async {
    final next = isDark(context) ? ThemeMode.light : ThemeMode.dark;
    _mode = next;
    notifyListeners();
    await _storage.saveThemeMode(next.name);
  }

  static ThemeMode _parse(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
