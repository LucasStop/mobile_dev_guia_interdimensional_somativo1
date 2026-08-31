import 'package:flutter/material.dart';

/// Tema do app, com as decisões de acessibilidade centralizadas (RF10).
///
/// Três coisas ficam aqui em vez de espalhadas pelas telas: o contraste das
/// cores, o tamanho mínimo dos alvos de toque e o teto do aumento de fonte.
class AppTheme {
  /// Verde-ciano da série. Serve de semente para as duas variantes.
  static const _seed = Color(0xFF00B5CC);

  /// `contrastLevel` acima do padrão empurra o Material 3 a gerar pares de
  /// texto e fundo com separação maior, em vez de confiar no contraste
  /// mínimo que a paleta padrão aceita.
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      contrastLevel: 0.3,
    );

    // 48dp é o alvo de toque mínimo recomendado para dedo; abaixo disso o
    // botão fica difícil de acertar, o que é o item de área de toque do RF10.
    const minimumTarget = Size(48, 48);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: minimumTarget),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: minimumTarget),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: minimumTarget),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: minimumTarget),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
    );
  }

  /// Teto para o aumento de fonte do sistema.
  ///
  /// O app respeita a preferência do usuário — o texto cresce e os cards
  /// crescem junto — mas acima de 1.6x nem uma grade de duas colunas comporta
  /// o nome de um personagem, então o fator para nesse ponto em vez de cortar
  /// texto na tela.
  static TextScaler clampTextScaler(BuildContext context) {
    return MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.6,
    );
  }
}
