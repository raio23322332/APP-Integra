class Cidade {
  final String id;
  final String nome;
  final String estadoId;

  Cidade({
    required this.id,
    required this.nome,
    required this.estadoId,
  });

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json['ID']?.toString() ?? '',
      nome: json['Nome']?.toString() ?? '',
      estadoId: json['Estado']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Nome': nome,
      'Estado': estadoId,
    };
  }

  @override
  String toString() => nome;
}
