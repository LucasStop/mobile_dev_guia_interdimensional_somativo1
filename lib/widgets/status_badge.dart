import 'package:flutter/material.dart';

import '../models/character.dart';
import '../theme/app_theme.dart';

/// Selo de status do personagem — vivo, morto ou desconhecido.
///
/// O fundo inteiro do selo é a cor do status, não só um indicador pequeno:
/// dá para reconhecer o status pela mancha de cor sem precisar ler o texto.
/// O texto continua presente por cima — sem ele, a cor sozinha não serve para
/// quem não distingue verde de vermelho nem para o leitor de tela (RF10).
class StatusBadge extends StatelessWidget {
  final Character character;

  const StatusBadge({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = switch (character.status.toLowerCase()) {
      'alive' => AppTheme.aliveColor(brightness),
      'dead' => AppTheme.deadColor(brightness),
      _ => AppTheme.unknownColor(brightness),
    };

    // O fundo é a própria cor do status, então o texto precisa do lado
    // oposto do espectro para continuar legível em qualquer uma delas.
    final textColor = ThemeData.estimateBrightnessForColor(color) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;

    return Semantics(
      label: 'Status: ${character.statusLabel}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          character.statusLabel,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
