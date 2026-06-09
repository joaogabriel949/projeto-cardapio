class UserSession {
  // Singleton
  static final UserSession _instance = UserSession._internal();
  static UserSession get instance => _instance;
  UserSession._internal();

  int? _userId;
  String? _userName;

  int? get userId => _userId;
  String? get userName => _userName;

  void set(int id, String nome) {
    _userId = id;
    _userName = nome;
  }

  void clear() {
    _userId = null;
    _userName = null;
  }
}
