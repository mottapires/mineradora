import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_mineradora/models/user.dart';
import 'package:app_mineradora/utils/constants.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService._();

  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.BASE_URL}${Constants.LOGIN_ENDPOINT}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final user = User.fromJson(data);
          
          // Salvar token e dados do usuário
          await _secureStorage.write(
            key: Constants.SECURE_STORAGE_TOKEN_KEY,
            value: user.token,
          );
          
          await _secureStorage.write(
            key: Constants.SECURE_STORAGE_USER_KEY,
            value: jsonEncode(user.toJson()),
          );
          
          return user;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final userData = await _secureStorage.read(
        key: Constants.SECURE_STORAGE_USER_KEY,
      );
      
      if (userData != null) {
        final userJson = jsonDecode(userData);
        return User.fromJson({'user': userJson, 'token': userJson['token']});
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(
      key: Constants.SECURE_STORAGE_TOKEN_KEY,
    );
    
    await _secureStorage.delete(
      key: Constants.SECURE_STORAGE_USER_KEY,
    );
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(
      key: Constants.SECURE_STORAGE_TOKEN_KEY,
    );
  }
}