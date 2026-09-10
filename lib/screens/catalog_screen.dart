import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character.dart';
import '../providers/auth_provider.dart';
import '../providers/character_list_provider.dart';
import '../providers/theme_provider.dart';
import '../services/rick_morty_service.dart';
import '../widgets/character_card.dart';
import '../widgets/character_search_field.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'character_detail_screen.dart';
import 'marked_list_screen.dart';
import 'profile_screen.dart';
import 'search_results_screen.dart';

/// Tela principal (RF01): grade paginada de personagens.
class CatalogScreen extends StatefulWidget {
  /// Injetável para que os testes possam rodar a tela contra respostas
  /// controladas, sem tocar a rede.
  final RickMortyService? service;

  const CatalogScreen({super.key, this.service});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final RickMortyService _service = widget.service ?? RickMortyService();

  /// Lista acumulada: "Carregar Mais" acrescenta à grade em vez de trocá-la.
  final List<Character> _characters = [];

  /// O `FutureBuilder` governa apenas a **primeira** carga — é ele que decide
  /// entre indicador de progresso, erro e grade. As páginas seguintes chegam
  /// por `setState` sobre `_characters`, porque refazer o Future a cada
  /// "Carregar Mais" reconstruiria a tela inteira e perderia a rolagem.
  late Future<void> _initialLoad;

  int _page = 1;
  bool _hasNext = true;
  bool _isLoadingMore = false;
  String? _loadMoreError;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  /// Dispara a próxima página perto do fim da rolagem, em vez de esperar um
  /// toque em "Carregar Mais". `_loadMore` já se protege contra chamada
  /// dupla e contra pedir página depois da última.
  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    try {
      await _loadFirstPage();
    } on ApiException {
      // Conteúdo antigo continua na tela; só a "puxada" some.
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadFirstPage() async {
    final page = await _service.fetchCharacters(page: 1);
    _characters
      ..clear()
      ..addAll(page.characters);
    _page = 1;
    _hasNext = page.hasNext;
  }

  void _retryInitialLoad() {
    setState(() {
      _loadMoreError = null;
      _initialLoad = _loadFirstPage();
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasNext) return;

    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });

    try {
      final next = await _service.fetchCharacters(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _characters.addAll(next.characters);
        _page += 1;
        _hasNext = next.hasNext;
        _isLoadingMore = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      // A grade já carregada continua na tela: a falha em buscar a próxima
      // página não pode apagar o que o usuário já estava vendo.
      setState(() {
        _isLoadingMore = false;
        _loadMoreError = e.message;
      });
    }
  }

  void _openDetail(Character character) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterDetailScreen(character: character),
      ),
    );
  }

  /// Um resultado só vai direto pro detalhe, como antes; mais de um vira
  /// grade de resultados.
  void _openSearchResults(List<Character> results) {
    if (results.length == 1) {
      _openDetail(results.first);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(characters: results),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guia Interdimensional'),
        actions: [
          _ListShortcut<WatchedProvider>(
            icon: Icons.visibility_outlined,
            label: 'Vistos',
            destination: const MarkedListScreen<WatchedProvider>(
              title: 'Vistos',
              emptyIcon: Icons.visibility_off_outlined,
              emptyMessage:
                  'Você ainda não marcou nenhum personagem como visto.\n'
                  'Abra um personagem e toque no ícone de olho.',
            ),
          ),
          _ListShortcut<FavoritesProvider>(
            icon: Icons.star_border,
            label: 'Favoritos',
            destination: const MarkedListScreen<FavoritesProvider>(
              title: 'Favoritos',
              emptyIcon: Icons.star_border,
              emptyMessage:
                  'Você ainda não favoritou nenhum personagem.\n'
                  'Abra um personagem e toque na estrela.',
            ),
          ),
          const _ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da conta',
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          CharacterSearchField(service: _service, onResults: _openSearchResults),
          Expanded(
            child: FutureBuilder<void>(
              future: _initialLoad,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView(message: 'Carregando o catálogo...');
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error is ApiException
                        ? snapshot.error.toString()
                        : 'Não foi possível carregar o catálogo.',
                    onRetry: _retryInitialLoad,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: _CatalogGrid(
                    controller: _scrollController,
                    characters: _characters,
                    hasNext: _hasNext,
                    isLoadingMore: _isLoadingMore,
                    loadMoreError: _loadMoreError,
                    onLoadMore: _loadMore,
                    onOpenDetail: _openDetail,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Atalho da barra superior para uma lista marcada, com a contagem atual
/// (RF05). A contagem vem do provider, então sobe e desce junto com o que o
/// usuário marca na tela de detalhes.
class _ListShortcut<T extends CharacterListProvider> extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget destination;

  const _ListShortcut({
    required this.icon,
    required this.label,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final count = context.select<T, int>((provider) => provider.count);

    return IconButton(
      tooltip: label,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: Icon(icon),
      ),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => destination),
      ),
    );
  }
}

/// Alterna entre o tema claro e o escuro da série (opcional dark mode, RF10).
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark(context);

    return IconButton(
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      tooltip: isDark ? 'Ativar tema claro' : 'Ativar tema escuro',
      onPressed: () => context.read<ThemeProvider>().toggle(context),
    );
  }
}

class _CatalogGrid extends StatelessWidget {
  final ScrollController controller;
  final List<Character> characters;
  final bool hasNext;
  final bool isLoadingMore;
  final String? loadMoreError;
  final VoidCallback onLoadMore;
  final void Function(Character) onOpenDetail;

  const _CatalogGrid({
    required this.controller,
    required this.characters,
    required this.hasNext,
    required this.isLoadingMore,
    required this.loadMoreError,
    required this.onLoadMore,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    // A grade acompanha a largura disponível e o tamanho de fonte do sistema:
    // com fonte grande os cards ficam mais altos em vez de cortar o texto
    // (RF10).
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final columns = width ~/ 180 == 0 ? 2 : (width ~/ 180).clamp(2, 5);

    return CustomScrollView(
      controller: controller,
      // RefreshIndicator precisa de física sempre rolável mesmo quando o
      // conteúdo cabe inteiro na tela, senão o gesto de puxar não dispara.
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid.builder(
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
                onTap: () => onOpenDetail(character),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
            child: _LoadMoreSection(
              hasNext: hasNext,
              isLoading: isLoadingMore,
              errorMessage: loadMoreError,
              onLoadMore: onLoadMore,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rodapé da grade. Some quando a API sinaliza que não há próxima página
/// (`info.next == null`, o que acontece na página 42) — sem isso o botão
/// continuaria pedindo uma página inexistente e devolvendo erro.
class _LoadMoreSection extends StatelessWidget {
  final bool hasNext;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onLoadMore;

  const _LoadMoreSection({
    required this.hasNext,
    required this.isLoading,
    required this.errorMessage,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!hasNext) {
      return Semantics(
        liveRegion: true,
        child: Text(
          'Você chegou ao fim do catálogo.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Caminho feliz: a rolagem já dispara a próxima página sozinha (ver
    // `_onScroll` em CatalogScreen), sem precisar de botão. O botão só volta
    // quando a tentativa automática falhou — aí é retry explícito.
    if (errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onLoadMore,
          icon: const Icon(Icons.expand_more),
          label: const Text('Tentar novamente'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 48),
          ),
        ),
      ],
    );
  }
}
