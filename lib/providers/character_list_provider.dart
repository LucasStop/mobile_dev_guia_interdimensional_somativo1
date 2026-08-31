import 'package:flutter/foundation.dart';

import '../data/local_storage.dart';
import '../models/character.dart';

/// Estado compartilhado de uma lista de personagens marcada pelo usuário
/// (RF04, RF06, RF07).
///
/// Favoritos e Vistos têm exatamente o mesmo comportamento — alternar um
/// personagem, consultar se está na lista, sobreviver ao fechamento do app — e
/// diferem só em qual chave do armazenamento usam. A regra fica aqui e cada
/// lista declara apenas a sua leitura e a sua escrita.
abstract class CharacterListProvider extends ChangeNotifier {
  final LocalStorage storage;
  final List<Character> _items;

  CharacterListProvider(this.storage) : _items = [] {
    _items.addAll(readFromStorage());
  }

  /// Cópia imutável: a lista só muda por `toggle`, nunca por quem a exibe.
  List<Character> get items => List.unmodifiable(_items);

  int get count => _items.length;

  bool contains(int characterId) =>
      _items.any((c) => c.id == characterId);

  /// Adiciona ou remove, grava em disco e avisa a interface — é o que faz a
  /// tela de lista se atualizar sozinha quando o item é desmarcado na tela de
  /// detalhes (RF05).
  Future<void> toggle(Character character) async {
    final index = _items.indexWhere((c) => c.id == character.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(character);
    }
    notifyListeners();
    await writeToStorage(_items);
  }

  @protected
  List<Character> readFromStorage();

  @protected
  Future<void> writeToStorage(List<Character> characters);
}

/// RF04/RF05 — favoritos.
class FavoritesProvider extends CharacterListProvider {
  FavoritesProvider(super.storage);

  @override
  List<Character> readFromStorage() => storage.readFavorites();

  @override
  Future<void> writeToStorage(List<Character> characters) =>
      storage.writeFavorites(characters);
}

/// RF07 — personagens que o usuário já viu na série.
class WatchedProvider extends CharacterListProvider {
  WatchedProvider(super.storage);

  @override
  List<Character> readFromStorage() => storage.readWatched();

  @override
  Future<void> writeToStorage(List<Character> characters) =>
      storage.writeWatched(characters);
}
