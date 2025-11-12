// services/socket_service.dart
import 'package:rideupt_app/utils/app_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  
  IO.Socket? get socket => _socket;

  void connect(String token) {
    _socket = IO.io(AppConfig.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': { 'token': token }
    });
    _socket!.connect();

    _socket!.onConnect((_) => print('Socket Conectado'));
    _socket!.onDisconnect((_) => print('Socket Desconectado'));
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void joinTripRoom(String tripId) {
    _socket?.emit('joinTripRoom', tripId);
  }

  // Escuchar eventos
  void listenForNewBooking(Function(dynamic) handler) {
    _socket?.on('newBookingRequest', handler);
  }
  
  void listenForTripUpdate(Function(dynamic) handler) {
    _socket?.on('tripUpdated', handler);
  }
}