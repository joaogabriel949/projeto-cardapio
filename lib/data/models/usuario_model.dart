class Usuario {
  final int? id;
  final String nome;
  final String? foto;
  final String dataNascimento;

  Usuario({
    this.id,
    required this.nome,
    this.foto,
    required this.dataNascimento,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      foto: map['foto'] as String?,
      dataNascimento: (map['data_nascimento'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      if (foto != null) 'foto': foto,
      'data_nascimento': dataNascimento,
    };
  }
}
