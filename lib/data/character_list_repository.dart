import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/character.dart';

/// Acesso a uma lista de personagens marcada pelo usuário — favoritos ou
/// vistos (RF04/RF05/RF06/RF07).
///
/// A implementação real fica na nuvem (Supabase); os testes usam um fake em
/// memória com a mesma interface, sem tocar rede.
abstract class CharacterListRepository {
  Future<List<Character>> fetchAll();
  Future<void> add(Character character);
  Future<void> remove(int characterId);
}

/// Favoritos e vistos moram na mesma tabela `character_list_entries`,
/// diferenciados pela coluna `list_type` — a Row Level Security do banco já
/// garante que cada usuário só enxerga as próprias linhas.
class SupabaseCharacterListRepository implements CharacterListRepository {
  final SupabaseClient _client;
  final String _listType;

  SupabaseCharacterListRepository(this._client, this._listType);

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Nenhum usuário autenticado.');
    }
    return id;
  }

  @override
  Future<List<Character>> fetchAll() async {
    final rows = await _client
        .from('character_list_entries')
        .select('character')
        .eq('list_type', _listType);

    return rows
        .map((row) => Character.fromJson(row['character'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> add(Character character) async {
    await _client.from('character_list_entries').upsert({
      'user_id': _userId,
      'character_id': character.id,
      'list_type': _listType,
      'character': character.toJson(),
    });
  }

  @override
  Future<void> remove(int characterId) async {
    await _client
        .from('character_list_entries')
        .delete()
        .eq('character_id', characterId)
        .eq('list_type', _listType);
  }
}
