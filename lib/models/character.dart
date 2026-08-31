/// Personagem do catálogo (RF01, RF03).
///
/// A lista paginada de `/character` já devolve o personagem inteiro, então
/// esta classe cobre tanto a grade quanto a tela de detalhes.
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String imageUrl;

  /// Nome do local de origem. Pode ser "unknown".
  final String originName;

  /// URL do local de origem. Vem **vazia** quando a origem é desconhecida
  /// (ex: personagem 8, "Adjudicator Rick") — por isso é nula aqui, e a tela
  /// de detalhes não tenta buscar o local nesse caso.
  final String? originUrl;

  final String lastKnownLocation;

  /// URLs dos episódios em que aparece, na ordem de exibição.
  final List<String> episodeUrls;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.imageUrl,
    required this.originName,
    required this.originUrl,
    required this.lastKnownLocation,
    required this.episodeUrls,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    final origin = json['origin'] as Map<String, dynamic>? ?? const {};
    final location = json['location'] as Map<String, dynamic>? ?? const {};
    final originUrl = origin['url'] as String? ?? '';

    return Character(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Desconhecido',
      status: json['status'] as String? ?? 'unknown',
      species: json['species'] as String? ?? 'unknown',
      gender: json['gender'] as String? ?? 'unknown',
      imageUrl: json['image'] as String? ?? '',
      originName: origin['name'] as String? ?? 'unknown',
      originUrl: originUrl.isEmpty ? null : originUrl,
      lastKnownLocation: location['name'] as String? ?? 'unknown',
      episodeUrls: (json['episode'] as List<dynamic>? ?? const [])
          .cast<String>(),
    );
  }

  /// Rótulo em português para a UI e para o leitor de tela (RF10).
  String get statusLabel => switch (status.toLowerCase()) {
        'alive' => 'Vivo',
        'dead' => 'Morto',
        _ => 'Desconhecido',
      };

  String get genderLabel => switch (gender.toLowerCase()) {
        'male' => 'Masculino',
        'female' => 'Feminino',
        'genderless' => 'Sem gênero',
        _ => 'Desconhecido',
      };

  bool get hasKnownOrigin => originUrl != null;
}
