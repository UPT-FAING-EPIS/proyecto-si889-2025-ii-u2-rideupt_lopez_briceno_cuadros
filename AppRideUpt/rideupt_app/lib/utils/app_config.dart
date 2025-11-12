// lib/utils/app_config.dart

import 'dart:io' show Platform;

class AppConfig {
  // =======================================================================
  // --- ¡SELECTOR DE ENTORNO! ---
  // Cambia este valor a 'true' para apuntar al servidor Debian.
  // Cambia este valor a 'false' para apuntar a tu entorno local (localhost/Docker).
  // =======================================================================
  static const bool _useServer = true;

  // --- CONFIGURACIÓN PARA EL SERVIDOR DE DESARROLLO (DEBIAN) ---
  // Reemplaza esta IP con la IP pública de tu servidor.
  static const String _serverIp = "161.132.50.113";
  static const String _serverPort = "3000";

  // --- CONFIGURACIÓN PARA EL ENTORNO LOCAL (TU PC) ---
  static String get _localHost {
    if (Platform.isAndroid) {
      // IP especial para que el emulador de Android se conecte al localhost de tu PC.
      return '10.0.2.2';
    } else {
      // Para el simulador de iOS y otras plataformas, 'localhost' funciona.
      return 'localhost';
    }
  }
  static const String _localPort = "3000";


  // --- GETTERS PÚBLICOS QUE LA APP USARÁ ---
  // Estos getters deciden qué configuración usar basándose en la variable _useServer.

  /// Devuelve la URL base para las peticiones de la API REST.
  /// Ejemplo: http://TU_IP:3000/api
  static String get baseUrl {
    final host = _useServer ? _serverIp : _localHost;
    final port = _useServer ? _serverPort : _localPort;
    return 'http://$host:$port/api';
  }

  /// Devuelve la URL base para la conexión de Socket.IO.
  /// Ejemplo: http://TU_IP:3000
  static String get socketUrl {
    final host = _useServer ? _serverIp : _localHost;
    final port = _useServer ? _serverPort : _localPort;
    return 'http://$host:$port';
  }
}