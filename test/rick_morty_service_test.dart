import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_dev_guia_interdimensional_somativo1/services/rick_morty_service.dart';

/// Testes do contato com a API (RF01, RF03, RF08, RF09).
///
/// As respostas são fixas e vêm do formato real da Rick and Morty API — o
/// objetivo é travar os comportamentos que já causaram problema: fim da
/// paginação, 404 da busca e a troca de formato do endpoint de episódios.
void main() {
  Map<String, dynamic> character(int id, String name) => {
        'id': id,
        'name': name,
        'status': 'Alive',
        'species': 'Human',
        'gender': 'Male',
        'image': 'https://example.test/$id.jpeg',
        'origin': {'name': 'Earth', 'url': 'https://example.test/location/1'},
        'location': {'name': 'Citadel'},
        'episode': ['https://example.test/episode/1'],
      };

  RickMortyService serviceReturning(
    Object body, {
    int statusCode = 200,
  }) {
    return RickMortyService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode(body),
          statusCode,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
  }

  group('fetchCharacters', () {
    test('lê a lista e sinaliza que existe próxima página', () async {
      final service = serviceReturning({
        'info': {'next': 'https://example.test/character?page=2'},
        'results': [character(1, 'Rick Sanchez'), character(2, 'Morty Smith')],
      });

      final page = await service.fetchCharacters(page: 1);

      expect(page.characters, hasLength(2));
      expect(page.characters.first.name, 'Rick Sanchez');
      expect(page.hasNext, isTrue);
    });

    test('marca o fim da lista quando info.next vem nulo', () async {
      // É o que a API devolve na página 42, e o que faz o botão
      // "Carregar Mais" desaparecer.
      final service = serviceReturning({
        'info': {'next': null},
        'results': [character(826, 'Butter Robot')],
      });

      final page = await service.fetchCharacters(page: 42);

      expect(page.hasNext, isFalse);
    });
  });

  group('searchCharacters', () {
    test('devolve todos os resultados, não só o primeiro', () async {
      final service = serviceReturning({
        'info': {'next': null},
        'results': [character(2, 'Morty Smith'), character(3, 'Morty Jr.')],
      });

      final found = await service.searchCharacters('morty');

      expect(found.map((c) => c.id), [2, 3]);
    });

    test('converte o 404 da API em mensagem para o usuário', () async {
      final service = serviceReturning(
        {'error': 'There is nothing here'},
        statusCode: 404,
      );

      expect(
        () => service.searchCharacters('zzzz'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Nenhum personagem encontrado'),
          ),
        ),
      );
    });
  });

  group('fetchEpisodes', () {
    test('aceita o objeto único que a API devolve para um id só', () async {
      final service = serviceReturning({
        'id': 1,
        'name': 'Pilot',
        'air_date': 'December 2, 2013',
        'episode': 'S01E01',
      });

      final episodes = await service.fetchEpisodes([
        'https://example.test/episode/1',
      ]);

      expect(episodes, hasLength(1));
      expect(episodes.single.code, 'S01E01');
    });

    test('aceita o array que a API devolve para vários ids', () async {
      final service = serviceReturning([
        {'id': 1, 'name': 'Pilot', 'air_date': '...', 'episode': 'S01E01'},
        {'id': 2, 'name': 'Lawnmower Dog', 'air_date': '...', 'episode': 'S01E02'},
      ]);

      final episodes = await service.fetchEpisodes([
        'https://example.test/episode/1',
        'https://example.test/episode/2',
      ]);

      expect(episodes.map((e) => e.code), ['S01E01', 'S01E02']);
    });

    test('não chama a rede quando o personagem não tem episódios', () async {
      var calls = 0;
      final service = RickMortyService(
        client: MockClient((_) async {
          calls++;
          return http.Response('[]', 200);
        }),
      );

      expect(await service.fetchEpisodes(const []), isEmpty);
      expect(calls, 0);
    });
  });

  test('falha de conexão vira ApiException legível', () async {
    final service = RickMortyService(
      client: MockClient((_) async => throw const SocketExceptionStub()),
    );

    expect(
      () => service.fetchCharacters(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Verifique sua internet'),
        ),
      ),
    );
  });
}

/// Substituto de falha de rede, para não depender de `dart:io` no teste.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
