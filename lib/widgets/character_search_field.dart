import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/rick_morty_service.dart';

/// Busca por nome (RF08).
///
/// Fica fora do `FutureBuilder` do catálogo de propósito: mesmo que a grade
/// tenha falhado ao carregar, a busca continua disponível.
class CharacterSearchField extends StatefulWidget {
  final RickMortyService service;
  final void Function(List<Character>) onResults;

  const CharacterSearchField({
    super.key,
    required this.service,
    required this.onResults,
  });

  @override
  State<CharacterSearchField> createState() => _CharacterSearchFieldState();
}

class _CharacterSearchFieldState extends State<CharacterSearchField> {
  final _controller = TextEditingController();

  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final term = _controller.text.trim();
    if (term.isEmpty) {
      setState(() => _errorMessage = 'Digite um nome para buscar.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await widget.service.searchCharacters(term);
      if (!mounted) return;
      setState(() => _isSearching = false);
      widget.onResults(results);
    } on ApiException catch (e) {
      // A API responde 404 quando nenhum nome bate. O service já transforma
      // isso em texto para o usuário, então aqui é só exibir.
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    labelText: 'Buscar personagem',
                    hintText: 'Ex.: Morty',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                width: 48,
                child: _isSearching
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : IconButton.filled(
                        onPressed: _search,
                        icon: const Icon(Icons.arrow_forward),
                        tooltip: 'Buscar',
                      ),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
