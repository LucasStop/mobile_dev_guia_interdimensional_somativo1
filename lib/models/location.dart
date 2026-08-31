/// Local de origem de um personagem (RF03).
///
/// Só existe através da segunda requisição da tela de detalhes: `type`,
/// `dimension` e a contagem de residentes não vêm na listagem do catálogo.
class OriginLocation {
  final int id;
  final String name;
  final String type;
  final String dimension;
  final int residentCount;

  const OriginLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    required this.residentCount,
  });

  factory OriginLocation.fromJson(Map<String, dynamic> json) {
    return OriginLocation(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Desconhecido',
      type: json['type'] as String? ?? 'unknown',
      dimension: json['dimension'] as String? ?? 'unknown',
      residentCount: (json['residents'] as List<dynamic>? ?? const []).length,
    );
  }
}
