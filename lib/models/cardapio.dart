class Cardapio {
  final int? id;
  final int? usuarioId;
  final int? cafeId;
  final int? almocoId;
  final int? jantaId;
  final String? pacienteNome;
  final String? cafeNome;
  final String? almocoNome;
  final String? jantaNome;

  const Cardapio({
    this.id,
    this.usuarioId,
    this.cafeId,
    this.almocoId,
    this.jantaId,
    this.pacienteNome,
    this.cafeNome,
    this.almocoNome,
    this.jantaNome,
  });

  factory Cardapio.fromMap(Map<String, dynamic> map) => Cardapio(
        id: map['id'] as int?,
        usuarioId: map['usuario_id'] as int?,
        cafeId: map['cafe_id'] as int?,
        almocoId: map['almoco_id'] as int?,
        jantaId: map['janta_id'] as int?,
        pacienteNome: map['paciente_nome'] as String?,
        cafeNome: map['cafe_nome'] as String?,
        almocoNome: map['almoco_nome'] as String?,
        jantaNome: map['janta_nome'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        if (usuarioId != null) 'usuario_id': usuarioId,
        if (cafeId != null) 'cafe_id': cafeId,
        if (almocoId != null) 'almoco_id': almocoId,
        if (jantaId != null) 'janta_id': jantaId,
      };
}
