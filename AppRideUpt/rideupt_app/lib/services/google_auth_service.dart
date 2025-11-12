// lib/services/google_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // CAMBIO 1: El constructor de GoogleSignIn ya no lleva parámetros.
  // Las configuraciones como 'scopes' se pasan directamente al método signIn.
  // La restricción de dominio ('hostedDomain') ahora se debe configurar en
  // la consola de Google Cloud para tu ID de cliente de OAuth.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  // URL del backend - CAMBIAR según tu servidor
  final String _backendUrl = 'http://161.132.50.113:3000';

  /// Iniciar sesión con Google
  ///
  /// Retorna un Map con los datos del usuario si es exitoso, null si el usuario canceló
  /// Lanza una excepción si hay un error
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔐 Iniciando Google Sign-In...');

      // 1. Trigger the authentication flow
      // CAMBIO 2: Los scopes se aseguran aquí, aunque ya se definieron en el constructor.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        print('⚠️  Usuario canceló el inicio de sesión');
        return null;
      }

      print('✅ Usuario seleccionado: ${googleUser.email}');

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Verificar que tenemos el idToken
      if (googleAuth.idToken == null) {
        throw Exception('No se pudo obtener el token de autenticación de Google');
      }

      print('✅ Token de Google obtenido');

      // 3. Create a new credential
      // NO HAY CAMBIOS AQUÍ: El error de 'accessToken' era un síntoma del
      // problema de dependencias. Con las versiones correctas, esto funciona.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔄 Autenticando con Firebase...');

      // 4. Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('No se pudo autenticar con Firebase');
      }

      print('✅ Autenticado con Firebase');
      print('📧 Email: ${userCredential.user!.email}');

      // 5. Get Firebase ID token for backend
      final String? firebaseIdToken = await userCredential.user!.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('No se pudo obtener el token de Firebase');
      }

      print('🔄 Enviando token al backend...');

      // 6. Send to backend for validation and user creation
      final response = await http.post(
        Uri.parse('$_backendUrl/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': firebaseIdToken}),
      );

      print('📨 Respuesta del backend: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Autenticación exitosa en backend');
        print('🆔 User ID: ${data['_id']}');
        print('👤 Nombre: ${data['firstName']}');
        print('🎭 Rol: ${data['role']}');
        print('🆕 Nuevo usuario: ${data['isNewUser'] ?? false}');

        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error del servidor');
      }
    } on FirebaseAuthException catch (e) {
      print('🔴 Error de Firebase Auth: ${e.code}');
      print('📝 Mensaje: ${e.message}');

      // Mensajes de error específicos
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Ya existe una cuenta con este email usando otro método de inicio de sesión');
        case 'invalid-credential':
          throw Exception('Las credenciales son inválidas');
        case 'operation-not-allowed':
          throw Exception('Inicio de sesión con Google no está habilitado');
        case 'user-disabled':
          throw Exception('Esta cuenta ha sido deshabilitada');
        case 'user-not-found':
          throw Exception('No se encontró una cuenta con este email');
        case 'wrong-password':
          throw Exception('Contraseña incorrecta');
        default:
          throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      print('🔴 Error en Google Sign-In: $e');
      rethrow;
    }
  }

  /// Cerrar sesión de Google y Firebase
  Future<void> signOut() async {
    try {
      print('🚪 Cerrando sesión...');

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('🔴 Error al cerrar sesión: $e');
      rethrow;
    }
  }

  /// Verificar si hay un usuario autenticado actualmente
  User? get currentUser => _auth.currentUser;

  /// Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}