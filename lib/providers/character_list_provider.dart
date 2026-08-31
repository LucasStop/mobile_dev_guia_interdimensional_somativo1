import 'package:flutter/foundation.dart';

import '../data/character_list_repository.dart';
import '../models/character.dart';

/// Estado compartilhado de uma lista de personagens marcada pelo usuário
/// (RF04, RF06, RF07).
///
/// Favoritos e Vistos têm exatamente o mesmo comportamento — carregar da
/// nuvem, alternar um personagem, consultar se está na lista — e diferem só
/// no `list_type` que o repositório usa. A regra fica aqui; cada lista só
/// declara qual repositório é o seu.
abstract class CharacterListProvider extends ChangeNotifier {
  final CharacterListRepository repository;
  final List<Character> _items = [];

  bool _isLoading = false;
  String? _error;

  CharacterListProvider(this.repository);

  /// Cópia imutável: a lista só muda por `load`/`toggle`/`clear`, nunca por
  /// quem a exibe.
  List<Character> get items => List.unmodifiable(_items);

  int get count => _items.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool contains(int characterId) => _items.any((c) => c.id == characterId);

  /// Busca a lista na nuvem. Chamado pelo gate de sessão assim que o login é
  /// detectado — a leitura agora depende de rede, então não dá mais pra
  /// carregar no construtor como na versão local.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await repository.fetchAll();
      _items
        ..clear()
        ..addAll(fetched);
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      _error = 'Não foi possível carregar sua lista. Verifique sua internet.';
      notifyListeners();
    }
  }

  /// Adiciona ou remove com atualização otimista: a UI muda na hora, e
  /// desfaz sozinha se a chamada à nuvem falhar — sem isso, favoritar com a
  /// rede instável pareceria travado até a resposta chegar.
  Future<void> toggle(Character character) async {
    final index = _items.indexWhere((c) => c.id == character.id);
    final wasPresent = index >= 0;

    if (wasPresent) {
      _items.removeAt(index);
    } else {
      _items.add(character);
    }
    _error = null;
    notifyListeners();

    try {
      if (wasPresent) {
        await repository.remove(character.id);
      } else {
        await repository.add(character);
      }
    } catch (_) {
      if (wasPresent) {
        _items.insert(index, character);
      } else {
        _items.removeWhere((c) => c.id == character.id);
      }
      _error = 'Não foi possível salvar. Verifique sua internet e tente de novo.';
      notifyListeners();
    }
  }

  /// Esvazia a lista sem tocar a nuvem — usado no logout, pra não vazar dado
  /// de uma conta pra outra na mesma instância do app.
  void clear() {
    _items.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

/// RF04/RF05 — favoritos.
class FavoritesProvider extends CharacterListProvider {
  FavoritesProvider(super.repository);
}

/// RF07 — personagens que o usuário já viu na série.
class WatchedProvider extends CharacterListProvider {
  WatchedProvider(super.repository);
}
