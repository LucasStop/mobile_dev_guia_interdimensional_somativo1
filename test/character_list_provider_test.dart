import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/data/local_storage.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/models/character.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/providers/character_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testes do estado global e da persistência (RF04, RF05, RF06, RF07).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<LocalStorage> emptyStorage() async {
    SharedPreferences.setMockInitialValues({});
    return LocalStorage.open();
  }

  test('toggle adiciona e remove o personagem', () async {
    final favorites = FavoritesProvider(await emptyStorage());

    expect(favorites.contains(rick.id), isFalse);

    await favorites.toggle(rick);
    expect(favorites.contains(rick.id), isTrue);
    expect(favorites.count, 1);

    await favorites.toggle(rick);
    expect(favorites.contains(rick.id), isFalse);
    expect(favorites.count, 0);
  });

  test('notifica os ouvintes a cada mudança', () async {
    final favorites = FavoritesProvider(await emptyStorage());
    var notifications = 0;
    favorites.addListener(() => notifications++);

    await favorites.toggle(rick);
    await favorites.toggle(morty);
    await favorites.toggle(rick);

    expect(notifications, 3);
  });

  test('a lista sobrevive ao fechamento do app', () async {
    final storage = await emptyStorage();
    final favorites = FavoritesProvider(storage);

    await favorites.toggle(rick);
    await favorites.toggle(morty);

    // Um provider novo sobre o mesmo armazenamento é o que acontece no
    // próximo boot do app.
    final reopened = FavoritesProvider(await LocalStorage.open());

    expect(reopened.count, 2);
    expect(reopened.contains(rick.id), isTrue);
    expect(reopened.items.first.name, 'Rick Sanchez');
  });

  test('a origem desconhecida sobrevive à ida e volta do disco', () async {
    // Personagens como o "Adjudicator Rick" vêm da API sem URL de origem;
    // isso precisa continuar nulo depois de salvo e lido.
    final storage = await emptyStorage();
    await FavoritesProvider(storage).toggle(morty);

    final reopened = FavoritesProvider(await LocalStorage.open());

    expect(reopened.items.single.hasKnownOrigin, isFalse);
    expect(reopened.items.single.originUrl, isNull);
  });

  test('favoritos e vistos são listas independentes', () async {
    final storage = await emptyStorage();
    final favorites = FavoritesProvider(storage);
    final watched = WatchedProvider(storage);

    await favorites.toggle(rick);

    expect(favorites.contains(rick.id), isTrue);
    expect(watched.contains(rick.id), isFalse);
  });

  test('items não pode ser alterada por fora do provider', () async {
    final favorites = FavoritesProvider(await emptyStorage());
    await favorites.toggle(rick);

    expect(() => favorites.items.add(morty), throwsUnsupportedError);
  });
}
