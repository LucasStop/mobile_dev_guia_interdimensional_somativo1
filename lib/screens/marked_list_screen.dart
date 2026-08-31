import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character.dart';
import '../providers/character_list_provider.dart';
import '../widgets/character_card.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'character_detail_screen.dart';

/// Grade de uma lista marcada pelo usuário (RF05 e RF07).
///
/// Favoritos e Vistos são a mesma tela com outro provider e outro texto, então
/// existe uma implementação só, parametrizada pelo tipo do provider.
class MarkedListScreen<T extends CharacterListProvider> extends StatelessWidget {
  final String title;
  final IconData emptyIcon;
  final String emptyMessage;

  const MarkedListScreen({
    super.key,
    required this.title,
    required this.emptyIcon,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    // `watch` é o que faz a grade se refazer sozinha quando o item é
    // desmarcado na tela de detalhes, sem nenhum retorno manual de valor pela
    // pilha de navegação (RF05).
    final provider = context.watch<T>();
    final characters = provider.items;

    Widget body;
    if (provider.isLoading && characters.isEmpty) {
      body = const LoadingView(message: 'Carregando sua lista...');
    } else if (provider.error != null && characters.isEmpty) {
      body = ErrorView(message: provider.error!, onRetry: () => provider.load());
    } else if (characters.isEmpty) {
      body = _EmptyState(icon: emptyIcon, message: emptyMessage);
    } else {
      body = _Grid(characters: characters);
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }
}

class _Grid extends StatelessWidget {
  final List<Character> characters;

  const _Grid({required this.characters});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final columns = width ~/ 180 == 0 ? 2 : (width ~/ 180).clamp(2, 5);

    return GridView.builder(
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
