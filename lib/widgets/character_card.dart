import 'package:flutter/material.dart';

import '../models/character.dart';

/// Célula da grade do catálogo (RF01): imagem, nome e status.
class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        // Um nó semântico só para o card inteiro: o leitor de tela anuncia
        // "Rick Sanchez, Vivo, botão" em vez de ler imagem e textos soltos.
        child: Semantics(
          button: true,
          label: '${character.name}, ${character.statusLabel}',
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _CharacterImage(url: character.imageUrl)),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      character.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      character.statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Imagem do personagem com os três estados cobertos (RF01).
///
/// A Rick and Morty API sempre devolve `image` preenchido, então o caso "item
/// sem imagem" só aparece de verdade quando o arquivo não carrega — URL
/// quebrada, rede caindo no meio do download. É o `errorBuilder` que garante
/// que isso vire um placeholder em vez de um ícone de exceção ocupando a
/// célula.
class _CharacterImage extends StatelessWidget {
  final String url;

  const _CharacterImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImagePlaceholder();

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _ImagePlaceholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: Color(0x11000000),
          child: Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.person_off_outlined,
          size: 40,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
