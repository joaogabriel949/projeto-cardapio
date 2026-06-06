class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  int? usuarioId;
  String? usuarioNome;

  void set(int id, String nome) {
    usuarioId = id;
    usuarioNome = nome;
  }

  void clear() {
    usuarioId = null;
    usuarioNome = null;
  }
}
