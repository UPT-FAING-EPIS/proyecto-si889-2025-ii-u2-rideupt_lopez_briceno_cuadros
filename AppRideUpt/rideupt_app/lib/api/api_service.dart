import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

class ApiService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<dynamic> _handleRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(const Duration(seconds: 15));
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        // Para errores de validación, el backend puede enviar un array
        if (responseData['errors'] is List) {
          final firstError = responseData['errors'][0];
          throw HttpException(firstError['msg'] ?? 'Error de validación');
        }
        throw HttpException(responseData['message'] ?? 'Ocurrió un error desconocido');
      }
    } on SocketException {
      throw const SocketException('No se pudo conectar al servidor. Revisa tu conexión.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }

  // Petición POST pública (sin token)
  Future<dynamic> postPublic(String endpoint, Map<String, dynamic> data) async {
    return _handleRequest(
      http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ),
    );
  }
  
  // Peticiones con Token de Autenticación
  Future<dynamic> post(String endpoint, String token, Map<String, dynamic> data) async {
    return _handleRequest(
      http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      ),
    );
  }

  Future<dynamic> get(String endpoint, String token) async {
    return _handleRequest(
      http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<dynamic> put(String endpoint, String token, Map<String, dynamic> data) async {
    return _handleRequest(
      http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      ),
    );
  }

  Future<dynamic> delete(String endpoint, String token) async {
    return _handleRequest(
      http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}