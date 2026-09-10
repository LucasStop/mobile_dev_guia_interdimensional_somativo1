import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Tema do app: a paleta da série em duas variantes, com as decisões de
/// acessibilidade centralizadas (RF10).
///
/// As cores originais de Rick and Morty são claras e saturadas — o verde do
/// portal e o amarelo da camisa do Morty funcionam sobre fundo escuro, mas
/// reprovam em contraste como texto sobre branco. Por isso a variante clara
/// usa versões escurecidas das mesmas cores, em vez de repetir a paleta.
class AppTheme {
  // Paleta da série.
  static const portalGreen = Color(0xFF97CE4C); // verde do portal
  static const mortyYellow = Color(0xFFF0E14A); // camisa do Morty
  static const rickCyan = Color(0xFF24A0B5); // cabelo do Rick
  static const spaceGraphite = Color(0xFF10131A); // fundo escuro
  static const spaceSurface = Color(0xFF1B2029); // cards no escuro

  // Versões escurecidas, para texto e ícones sobre fundo claro.
  static const deepCyan = Color(0xFF1B7F94);
  static const deepGreen = Color(0xFF5C8A2E);

  /// Cores de status dos personagens, uma por variante do tema. São o par
  /// escuro/claro da mesma ideia: verde para vivo, vermelho para morto,
  /// neutro para desconhecido.
  static Color aliveColor(Brightness b) =>
      b == Brightness.dark ? portalGreen : deepGreen;

  static Color deadColor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFFFF6B6B) : const Color(0xFFB3261E);

  static Color unknownColor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = isDark
        ? const ColorScheme.dark(
            primary: portalGreen,
            onPrimary: Color(0xFF10240A),
            secondary: mortyYellow,
            onSecondary: Color(0xFF241F00),
            tertiary: rickCyan,
            surface: spaceSurface,
            onSurface: Color(0xFFE8EAED),
            onSurfaceVariant: Color(0xFFB6BCC4),
            surfaceContainerHighest: Color(0xFF262C36),
            error: Color(0xFFFF8A80),
            onError: Color(0xFF3A0A05),
          )
        : const ColorScheme.light(
            primary: deepCyan,
            onPrimary: Colors.white,
            secondary: deepGreen,
            onSecondary: Colors.white,
            tertiary: Color(0xFF7A6A00),
            surface: Colors.white,
            onSurface: Color(0xFF14181C),
            onSurfaceVariant: Color(0xFF44484D),
            surfaceContainerHighest: Color(0xFFE4E8E2),
            error: Color(0xFFB3261E),
            onError: Colors.white,
          );

    // 48dp é o alvo de toque mínimo recomendado para dedo; abaixo disso o
    // botão fica difícil de acertar, o que é o item de área de toque do RF10.
    const minimumTarget = Size(48, 48);

    // flex_color_scheme entra só pelo polimento de subtema (diálogo, switch,
    // slider, snackbar, etc.) — o ColorScheme continua sendo o mesmo definido
    // acima, com o mesmo racional de contraste. Os widgets que já tinham
    // ajuste manual (AppBar, Card, botões, input) são reafirmados abaixo por
    // cima do resultado, pra não perder nada do que já foi calibrado.
    final flexTheme = FlexColorScheme(
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackground: isDark ? spaceGraphite : const Color(0xFFF4F6F3),
      subThemesData: const FlexSubThemesData(),
    ).toTheme;

    return flexTheme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? spaceGraphite : const Color(0xFFF4F6F3),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: isDark
              ? BorderSide(color: scheme.surfaceContainerHighest)
              : BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: minimumTarget),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: minimumTarget,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: minimumTarget),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: minimumTarget),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
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
