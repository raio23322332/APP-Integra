class Estado {
  final String id;
  final String sigla;
  final String nome;

  Estado({
    required this.id,
    required this.sigla,
    required this.nome,
  });

  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      id: json['ID']?.toString() ?? '',
      sigla: json['Sigla']?.toString() ?? '',
      nome: json['Nome']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Sigla': sigla,
      'Nome': nome,
    };
  }

  @override
  String toString() => '$nome ($sigla)';
}
