// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../models/user.dart';
import 'package:rideupt_app/services/notification_service.dart';
import 'package:rideupt_app/services/socket_service.dart';
import 'package:rideupt_app/services/google_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  String? get token => _token;
  User? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Esta función está diseñada para recibir la PROMESA (Future) de una autenticación.
  Future<bool> _authenticate(Future<dynamic> authFuture) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      final response = await authFuture as Map<String, dynamic>;
      _token = response['token'];
      await _getUserProfile();

      await _registerDeviceForNotifications();
      SocketService().connect(_token!);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString()
        .replaceAll('HttpException: ', '')
        .replaceAll('SocketException: ', '')
        .replaceAll('Exception: ', '');
      
      print('Error de autenticación: $_errorMessage'); // Debug
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    return _authenticate(_apiService.postPublic('auth/login', {'email': email, 'password': password}));
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    return _authenticate(_apiService.postPublic('auth/register', userData));
  }

  Future<void> _getUserProfile() async {
    if (_token == null) return;
    try {
      final userData = await _apiService.get('users/profile', _token!);
      _user = User.fromJson(userData);
      notifyListeners();
    } catch (e) {
      // Si falla, es probable que el token sea inválido, así que cerramos sesión
      logout();
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return false;
    }
    _token = prefs.getString('token');
    if (_token == null) return false;
    
    await _getUserProfile();
    // La comprobación de isAuthenticated se basa en si _getUserProfile tuvo éxito
    return isAuthenticated;
  }

  Future<void> logout() async {
    print('🚪 Cerrando sesión...');
    
    // Desconectar socket
    try {
      SocketService().disconnect();
    } catch (e) {
      print('Error al desconectar socket: $e');
    }
    
    // Cerrar sesión de Google (si está usando Google Sign-In)
    try {
      final googleAuthService = GoogleAuthService();
      await googleAuthService.signOut();
      print('✅ Sesión de Google cerrada');
    } catch (e) {
      print('⚠️  No había sesión de Google activa');
    }
    
    // Limpiar datos locales
    _token = null;
    _user = null;
    
    // Limpiar storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpiar todo el storage
    
    notifyListeners();
    print('✅ Sesión cerrada completamente');
  }

  Future<bool> updateDriverProfile(Map<String, dynamic> vehicleData) async {
    _setLoading(true);
    if (_token == null) {
      _errorMessage = "No estás autenticado.";
      _setLoading(false);
      return false;
    }

    try {
      await _apiService.put('users/driver-profile', _token!, vehicleData);
      // Refrescar los datos del usuario para obtener el nuevo rol y vehículo
      await _getUserProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('HttpException: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> _registerDeviceForNotifications() async {
    if (_token == null) return;
    try {
      final fcmToken = await NotificationService().getFcmToken();
      if (fcmToken != null) {
        await _apiService.put('users/fcm-token', _token!, {'fcmToken': fcmToken});
        print("Token FCM registrado en el backend.");
      }
    } catch (e) {
      print("Error al registrar el token FCM: $e");
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ==========================================
  // GOOGLE SIGN-IN
  // ==========================================
  /// Establece los datos de autenticación directamente (para Google Sign-In)
  /// Este método se usa cuando el usuario ya fue autenticado por Firebase
  Future<void> setAuthData(String token, String userId, String role) async {
    _token = token;
    
    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    
    // Obtener perfil del usuario
    await _getUserProfile();
    
    // Registrar para notificaciones
    await _registerDeviceForNotifications();
    
    // Conectar socket
    SocketService().connect(token);
    
    notifyListeners();
  }
  
}