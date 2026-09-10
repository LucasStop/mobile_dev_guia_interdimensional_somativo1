import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/character.dart';
import '../models/episode.dart';
import '../models/location.dart';

/// Falha de comunicação já traduzida para uma mensagem que pode ir direto
/// para a tela (RF09).
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Uma página do catálogo: os personagens e se ainda existe página seguinte.
///
/// `hasNext` vem do campo `info.next` da API, que é `null` na última página
/// (a 42). É o que faz o botão "Carregar Mais" desaparecer no fim da lista.
class CharacterPage {
  final List<Character> characters;
  final bool hasNext;

  const CharacterPage({required this.characters, required this.hasNext});
}

/// Acesso à Rick and Morty API — pública, gratuita e sem chave de acesso.
class RickMortyService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';

  /// Quantos episódios a tela de detalhes carrega. A API aceita vários ids de
  /// uma vez, então isso é uma requisição só, não uma por episódio.
  static const int maxEpisodesOnDetail = 6;

  final http.Client _client;

  RickMortyService({http.Client? client}) : _client = client ?? http.Client();

  /// RF01 — lista paginada do catálogo, 20 personagens por página.
  Future<CharacterPage> fetchCharacters({int page = 1}) async {
    final json = await _getJson('$_baseUrl/character?page=$page');
    final info = json['info'] as Map<String, dynamic>? ?? const {};
    final results = json['results'] as List<dynamic>? ?? const [];

    return CharacterPage(
      characters: results
          .map((e) => Character.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: info['next'] != null,
    );
  }

  /// RF08 — busca por nome. A API devolve uma lista ordenada por relevância e
  /// responde 404 quando nada bate.
  Future<List<Character>> searchCharacters(String name) async {
    final query = Uri.encodeQueryComponent(name.trim());
    final json = await _getJson(
      '$_baseUrl/character/?name=$query',
      notFoundMessage: 'Nenhum personagem encontrado com esse nome.',
    );

    final results = json['results'] as List<dynamic>? ?? const [];
    if (results.isEmpty) {
      throw const ApiException('Nenhum personagem encontrado com esse nome.');
    }
    return results
        .map((e) => Character.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// RF03 — local de origem. Só é chamado quando o personagem tem origem
  /// conhecida (`Character.hasKnownOrigin`).
  Future<OriginLocation> fetchOriginLocation(String url) async {
    return OriginLocation.fromJson(await _getJson(url));
  }

  /// RF03 — episódios em que o personagem aparece.
  ///
  /// A API muda o formato da resposta conforme a quantidade de ids: com um id
  /// só devolve um objeto, com vários devolve um array. Os dois casos são
  /// normalizados para lista aqui.
  Future<List<Episode>> fetchEpisodes(List<String> episodeUrls) async {
    if (episodeUrls.isEmpty) return const [];

    final ids = episodeUrls
        .take(maxEpisodesOnDetail)
        .map((url) => url.split('/').last)
        .where((id) => id.isNotEmpty)
        .toList();
    if (ids.isEmpty) return const [];

    final decoded = await _get('$_baseUrl/episode/${ids.join(',')}');
    final list = decoded is List ? decoded : [decoded];

    return list
        .map((e) => Episode.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _client.close();

  Future<Map<String, dynamic>> _getJson(
    String url, {
    String? notFoundMessage,
  }) async {
    final decoded = await _get(url, notFoundMessage: notFoundMessage);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('A resposta do servidor veio em formato inesperado.');
    }
    return decoded;
  }

  /// Ponto único de contato com a rede: toda falha vira `ApiException` com
  /// texto pronto para a tela, então nenhuma tela precisa saber o que é um
  /// SocketException ou um status HTTP.
  Future<dynamic> _get(String url, {String? notFoundMessage}) async {
    final http.Response response;
    try {
      response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const ApiException(
        'Não foi possível conectar. Verifique sua internet e tente novamente.',
      );
    }

    if (response.statusCode == 404) {
      throw ApiException(notFoundMessage ?? 'Conteúdo não encontrado.');
    }
    if (response.statusCode != 200) {
      throw ApiException(
        'O servidor respondeu com erro ${response.statusCode}. Tente novamente.',
      );
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw const ApiException('Não foi possível ler a resposta do servidor.');
    }
  }
}
