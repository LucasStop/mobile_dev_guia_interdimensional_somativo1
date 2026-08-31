import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character.dart';
import '../models/episode.dart';
import '../models/location.dart';
import '../providers/character_list_provider.dart';
import '../services/rick_morty_service.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

/// O que só existe através da segunda requisição (RF03).
class _CharacterExtras {
  final OriginLocation? origin;
  final List<Episode> episodes;

  const _CharacterExtras({required this.origin, required this.episodes});
}

/// Tela de detalhes (RF02, RF03).
///
/// O personagem chega pronto da grade, mas os dados mais interessantes não
/// vêm na listagem: o tipo e a dimensão do local de origem e os episódios em
/// que ele aparece exigem uma segunda ida à API.
class CharacterDetailScreen extends StatefulWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  final _service = RickMortyService();
  late Future<_CharacterExtras> _extras;

  @override
  void initState() {
    super.initState();
    _extras = _loadExtras();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<_CharacterExtras> _loadExtras() async {
    final character = widget.character;

    // Personagens como o "Adjudicator Rick" têm origem "unknown" e URL vazia.
    // Buscar o local nesse caso resultaria em uma requisição a uma URL
    // inválida, então a origem simplesmente não é carregada.
    final originFuture = character.hasKnownOrigin
        ? _service.fetchOriginLocation(character.originUrl!)
        : Future<OriginLocation?>.value(null);

    final results = await Future.wait([
      originFuture,
      _service.fetchEpisodes(character.episodeUrls),
    ]);

    return _CharacterExtras(
      origin: results[0] as OriginLocation?,
      episodes: results[1] as List<Episode>,
    );
  }

  void _retry() => setState(() => _extras = _loadExtras());

  @override
  Widget build(BuildContext context) {
    final character = widget.character;

    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
        actions: [
          _MarkAction<WatchedProvider>(
            character: character,
            markedIcon: Icons.visibility,
            unmarkedIcon: Icons.visibility_outlined,
            markedLabel: 'Remover dos vistos',
            unmarkedLabel: 'Marcar como visto',
          ),
          _MarkAction<FavoritesProvider>(
            character: character,
            markedIcon: Icons.star,
            unmarkedIcon: Icons.star_border,
            markedLabel: 'Remover dos favoritos',
            unmarkedLabel: 'Adicionar aos favoritos',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _DetailHeader(character: character),
          const SizedBox(height: 8),
          _AttributeTile(
            icon: Icons.favorite_border,
            label: 'Status',
            value: character.statusLabel,
          ),
          _AttributeTile(
            icon: Icons.pets_outlined,
            label: 'Espécie',
            value: character.species,
          ),
          _AttributeTile(
            icon: Icons.wc_outlined,
            label: 'Gênero',
            value: character.genderLabel,
          ),
          _AttributeTile(
            icon: Icons.place_outlined,
            label: 'Última localização',
            value: character.lastKnownLocation,
          ),
          const Divider(height: 32),
          FutureBuilder<_CharacterExtras>(
            future: _extras,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: LoadingView(message: 'Buscando origem e episódios...'),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ErrorView(
                    message: snapshot.error is ApiException
                        ? snapshot.error.toString()
                        : 'Não foi possível carregar os detalhes.',
                    onRetry: _retry,
                  ),
                );
              }

              final extras = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionTitle('Origem'),
                  _OriginSection(
                    origin: extras.origin,
                    fallbackName: character.originName,
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle('Aparece em'),
                  _EpisodeSection(
                    episodes: extras.episodes,
                    totalEpisodes: character.episodeUrls.length,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Botão de marcar/desmarcar da barra superior (RF04 e RF07).
///
/// O ícone e o texto lido pelo leitor de tela mudam junto com o estado, então
/// quem usa TalkBack sabe se o personagem já está na lista antes de tocar.
class _MarkAction<T extends CharacterListProvider> extends StatelessWidget {
  final Character character;
  final IconData markedIcon;
  final IconData unmarkedIcon;
  final String markedLabel;
  final String unmarkedLabel;

  const _MarkAction({
    required this.character,
    required this.markedIcon,
    required this.unmarkedIcon,
    required this.markedLabel,
    required this.unmarkedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<T>();
    final isMarked = provider.contains(character.id);
    final label = isMarked ? markedLabel : unmarkedLabel;

    return IconButton(
      icon: Icon(isMarked ? markedIcon : unmarkedIcon),
      tooltip: label,
      onPressed: () => context.read<T>().toggle(character),
      // Alvo de toque de 48dp, o mínimo confortável para dedo (RF10).
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final Character character;

  const _DetailHeader({required this.character});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: character.imageUrl.isEmpty
              ? _placeholder(scheme)
              : Image.network(
                  character.imageUrl,
                  fit: BoxFit.cover,
                  semanticLabel: 'Foto de ${character.name}',
                  errorBuilder: (_, _, _) => _placeholder(scheme),
                ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Icon(
          Icons.person_off_outlined,
          size: 72,
          color: scheme.onSurfaceVariant,
          semanticLabel: 'Imagem indisponível',
        ),
      );
}

class _AttributeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AttributeTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _OriginSection extends StatelessWidget {
  final OriginLocation? origin;
  final String fallbackName;

  const _OriginSection({required this.origin, required this.fallbackName});

  @override
  Widget build(BuildContext context) {
    final origin = this.origin;

    if (origin == null) {
      return ListTile(
        leading: const Icon(Icons.help_outline),
        title: Text(fallbackName == 'unknown' ? 'Desconhecida' : fallbackName),
        subtitle: const Text('Sem informações de dimensão para este local.'),
      );
    }

    return Column(
      children: [
        _AttributeTile(
          icon: Icons.public,
          label: 'Local',
          value: origin.name,
        ),
        _AttributeTile(
          icon: Icons.category_outlined,
          label: 'Tipo',
          value: origin.type.isEmpty ? 'Desconhecido' : origin.type,
        ),
        _AttributeTile(
          icon: Icons.blur_circular_outlined,
          label: 'Dimensão',
          value: origin.dimension.isEmpty ? 'Desconhecida' : origin.dimension,
        ),
        _AttributeTile(
          icon: Icons.groups_outlined,
          label: 'Residentes',
          value: '${origin.residentCount}',
        ),
      ],
    );
  }
}

class _EpisodeSection extends StatelessWidget {
  final List<Episode> episodes;
  final int totalEpisodes;

  const _EpisodeSection({
    required this.episodes,
    required this.totalEpisodes,
  });

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return const ListTile(
        leading: Icon(Icons.tv_off_outlined),
        title: Text('Nenhum episódio registrado.'),
      );
    }

    final hidden = totalEpisodes - episodes.length;

    return Column(
      children: [
        for (final episode in episodes)
          Semantics(
            label: '${episode.code}, ${episode.name}, exibido em ${episode.airDate}',
            excludeSemantics: true,
            child: ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: Text('${episode.code} — ${episode.name}'),
              subtitle: Text(episode.airDate),
            ),
          ),
        if (hidden > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'e mais $hidden episódio${hidden == 1 ? '' : 's'}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
