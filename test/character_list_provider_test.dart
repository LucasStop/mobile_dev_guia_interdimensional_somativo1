import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/models/character.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/providers/character_list_provider.dart';

import 'support/fakes.dart';

/// Testes do estado global e da sincronização com a nuvem (RF04, RF05, RF06,
/// RF07).
void main() {
  const rick = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: 'Alive',
    species: 'Human',
    gender: 'Male',
    imageUrl: 'https://example.test/1.jpeg',
    originName: 'Earth (C-137)',
    originUrl: 'https://example.test/location/1',
    lastKnownLocation: 'Citadel of Ricks',
    episodeUrls: ['https://example.test/episode/1'],
  );

  const morty = Character(
    id: 2,
    name: 'Morty Smith',
    status: 'Alive',
    species: 'Human',
    gender: 'Male',
    imageUrl: 'https://example.test/2.jpeg',
    originName: 'unknown',
    originUrl: null,
    lastKnownLocation: 'Citadel of Ricks',
    episodeUrls: [],
  );

  test('load popula a lista a partir do repositório', () async {
    final favorites = FavoritesProvider(
      FakeCharacterListRepository(seed: [rick, morty]),
    );

    expect(favorites.count, 0);
    await favorites.load();

    expect(favorites.count, 2);
    expect(favorites.contains(rick.id), isTrue);
    expect(favorites.isLoading, isFalse);
  });

  test('toggle adiciona e remove, refletindo no repositório', () async {
    final repository = FakeCharacterListRepository();
    final favorites = FavoritesProvider(repository);

    expect(favorites.contains(rick.id), isFalse);

    await favorites.toggle(rick);
    expect(favorites.contains(rick.id), isTrue);
    expect((await repository.fetchAll()).map((c) => c.id), [rick.id]);

    await favorites.toggle(rick);
    expect(favorites.contains(rick.id), isFalse);
    expect(await repository.fetchAll(), isEmpty);
  });

  test('toggle é otimista mas desfaz sozinho se o repositório falhar', () async {
    final repository = FakeCharacterListRepository(failNextWrite: true);
    final favorites = FavoritesProvider(repository);

    await favorites.toggle(rick);

    // A UI já tinha mostrado o favorito marcado (update otimista); depois da
    // falha, volta pro estado real e avisa o motivo.
    expect(favorites.contains(rick.id), isFalse);
    expect(favorites.error, isNotNull);
  });

  test('notifica os ouvintes a cada mudança', () async {
    final favorites = FavoritesProvider(FakeCharacterListRepository());
    var notifications = 0;
    favorites.addListener(() => notifications++);

    await favorites.toggle(rick);
    await favorites.toggle(morty);
    await favorites.toggle(rick);

    expect(notifications, 3);
  });

  test('clear esvazia a lista sem tocar o repositório', () async {
    final repository = FakeCharacterListRepository(seed: [rick]);
    final favorites = FavoritesProvider(repository);
    await favorites.load();

    favorites.clear();

    expect(favorites.count, 0);
    expect(await repository.fetchAll(), hasLength(1));
  });

  test('favoritos e vistos são repositórios independentes', () async {
    final favorites = FavoritesProvider(FakeCharacterListRepository());
    final watched = WatchedProvider(FakeCharacterListRepository());

    await favorites.toggle(rick);

    expect(favorites.contains(rick.id), isTrue);
    expect(watched.contains(rick.id), isFalse);
  });

  test('a origem desconhecida sobrevive à ida e volta do repositório', () async {
    // Personagens como o "Adjudicator Rick" vêm da API sem URL de origem;
    // isso precisa continuar nulo depois de ir e voltar do repositório.
    final repository = FakeCharacterListRepository();
    await FavoritesProvider(repository).toggle(morty);

    final reopened = FavoritesProvider(repository);
    await reopened.load();

    expect(reopened.items.single.hasKnownOrigin, isFalse);
    expect(reopened.items.single.originUrl, isNull);
  });

  test('items não pode ser alterada por fora do provider', () async {
    final favorites = FavoritesProvider(FakeCharacterListRepository());
    await favorites.toggle(rick);

    expect(() => favorites.items.add(morty), throwsUnsupportedError);
  });
}
