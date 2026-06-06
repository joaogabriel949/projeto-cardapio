class Usuario {
  final int? id;
  final String nome;
  final String? foto;
  final String dataNascimento;

  const Usuario({
    this.id,
    required this.nome,
    this.foto,
    required this.dataNascimento,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
        id: map['id'] as int?,
        nome: map['nome'] as String? ?? '',
        foto: map['foto'] as String?,
        dataNascimento: map['data_nascimento'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'nome': nome,
        'foto': foto,
        'data_nascimento': dataNascimento,
      };
}
