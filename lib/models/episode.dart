/// Episódio em que um personagem aparece (RF03).
class Episode {
  final int id;

  /// Código no formato `S01E01`.
  final String code;
  final String name;
  final String airDate;

  const Episode({
    required this.id,
    required this.code,
    required this.name,
    required this.airDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      code: json['episode'] as String? ?? '',
      name: json['name'] as String? ?? 'Sem título',
      airDate: json['air_date'] as String? ?? '',
    );
  }
}
