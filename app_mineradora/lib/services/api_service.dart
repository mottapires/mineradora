import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_mineradora/models/loading_record.dart';
import 'package:app_mineradora/models/unloading_record.dart';
import 'package:app_mineradora/services/auth_service.dart';
import 'package:app_mineradora/utils/constants.dart';

class ApiService {
  static final ApiService instance = ApiService._();
  
  ApiService._();

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<bool> syncLoadingRecord(LoadingRecord record) async {
    try {
      final isConnected = await checkConnectivity();
      if (!isConnected) return false;

      final token = await AuthService.instance.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${Constants.BASE_URL}${Constants.OPERATOR_SYNC_ENDPOINT}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'placa': 'TEMP', // Campo necessário pela API
          'metros_cubicos': record.numViagens * 1.5, // Estimativa
          'valor_calculado': record.numViagens * 1.5 * 30, // Estimativa com preço padrão
          'latitude': null,
          'longitude': null,
          'foto': null,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> syncUnloadingRecord(UnloadingRecord record) async {
    try {
      final isConnected = await checkConnectivity();
      if (!isConnected) return false;

      final token = await AuthService.instance.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${Constants.BASE_URL}${Constants.POINTER_SYNC_ENDPOINT}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'placa': record.placa,
          'metros_cubicos': record.metrosCubicos,
          'valor_calculado': record.metrosCubicos * 30, // Preço padrão
          'latitude': null,
          'longitude': null,
          'foto': null,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Método para obter configurações do sistema
  Future<Map<String, dynamic>?> getConfig() async {
    try {
      final isConnected = await checkConnectivity();
      if (!isConnected) return null;

      final response = await http.get(
        Uri.parse('${Constants.BASE_URL}/get_config.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Método para verificar saúde da API
  Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.BASE_URL}/health.php'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}