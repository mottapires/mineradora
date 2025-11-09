class User {
  final int id;
  final String nome;
  final String email;
  final int idPerfil;
  final String token;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.idPerfil,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Verificar se é um objeto user direto ou encapsulado
    final userData = json.containsKey('user') ? json['user'] : json;
    
    return User(
      id: userData['id'] as int? ?? userData['user']['id'] as int,
      nome: userData['nome'] as String? ?? userData['user']['nome'] as String,
      email: userData['email'] as String? ?? userData['user']['email'] as String,
      idPerfil: userData['id_perfil'] as int? ?? userData['user']['id_perfil'] as int,
      token: json['token'] as String? ?? (userData['token'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'id_perfil': idPerfil,
      'token': token,
    };
  }
}