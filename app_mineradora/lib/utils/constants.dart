class Constants {
  // URL base da API - ajustar conforme o ambiente de deploy
  static const String BASE_URL = 'http://localhost/api';
  
  // Endpoints da API
  static const String LOGIN_ENDPOINT = '/login.php';
  static const String OPERATOR_SYNC_ENDPOINT = '/operador-sync.php';
  static const String POINTER_SYNC_ENDPOINT = '/apontador-sync.php';
  
  // Perfis de usuário
  static const int PERFIL_ADMIN = 1;
  static const int PERFIL_DIRETOR = 2;
  static const int PERFIL_SUPERVISOR = 3;
  static const int PERFIL_OPERADOR = 4;
  static const int PERFIL_APONTADOR = 5;
  
  // Chaves para armazenamento seguro
  static const String SECURE_STORAGE_TOKEN_KEY = 'user_token';
  static const String SECURE_STORAGE_USER_KEY = 'user_data';
  
  // Preço padrão por m³ (será atualizado via API)
  static const double PRECO_M3_PADRAO = 30.0;
}