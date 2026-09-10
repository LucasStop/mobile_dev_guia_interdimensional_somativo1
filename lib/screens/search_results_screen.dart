import 'package:flutter/material.dart';

import '../models/character.dart';
import '../widgets/character_card.dart';
import 'character_detail_screen.dart';

/// Resultados de busca por nome (RF08) — a API pode devolver mais de um
/// personagem batendo com o termo, então isso vira grade em vez de ir direto
/// pro detalhe.
class SearchResultsScreen extends StatelessWidget {
  final List<Character> characters;

  const SearchResultsScreen({super.key, required this.characters});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final columns = width ~/ 180 == 0 ? 2 : (width ~/ 180).clamp(2, 5);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados da busca')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: characters.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72 / textScale.clamp(1.0, 1.6),
        ),
        itemBuilder: (context, index) {
          final character = characters[index];
          return CharacterCard(
            character: character,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CharacterDetailScreen(character: character),
              ),
            ),
          );
        },
      ),
    );
  }
}
