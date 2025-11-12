// lib/providers/trip_provider.dart (ACTUALIZADO)
import 'package:flutter/material.dart';
import 'package:rideupt_app/api/api_service.dart';
import 'package:rideupt_app/models/trip.dart';
import 'package:rideupt_app/providers/auth_provider.dart';

class TripProvider with ChangeNotifier {
  final AuthProvider? _authProvider;
  final ApiService _apiService = ApiService();

  TripProvider(this._authProvider);

  List<Trip> _availableTrips = [];
  List<Trip> _myTrips = []; // Lista para "Mis Viajes"
  bool _isLoading = false;
  String _errorMessage = '';

  List<Trip> get availableTrips => _availableTrips;
  List<Trip> get myTrips => _myTrips;
  List<Trip> get activeMyTrips => _myTrips.where((trip) => 
    trip.isActive || trip.isFull || trip.isInProgress
  ).toList();
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  String? get _token => _authProvider?.token;

  Future<void> fetchAvailableTrips() async {
    if (_token == null) return;
    _setLoading(true);
    try {
      final List<dynamic> tripData = await _apiService.get('trips', _token!) as List<dynamic>;
      _availableTrips = tripData.map((data) => Trip.fromJson(data)).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('HttpException: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // --- ¡NUEVA FUNCIÓN! ---
  Future<void> fetchMyTrips() async {
    if (_token == null) return;
    
    final isDriver = _authProvider?.user?.role == 'driver';
    final endpoint = isDriver ? 'trips/my-driver-trips' : 'trips/my-passenger-trips';
    
    try {
      final response = await _apiService.get(endpoint, _token!);
      
      // Verificar que la respuesta sea una lista
      if (response is! List) {
        print('ERROR: Respuesta no es una lista, es: ${response.runtimeType}');
        print('Contenido: $response');
        _myTrips = [];
        _errorMessage = 'Error al obtener viajes';
        notifyListeners();
        return;
      }
      
      final List<dynamic> tripData = response;
      _myTrips = tripData.map((data) => Trip.fromJson(data as Map<String, dynamic>)).toList();
      
      print('✅ fetchMyTrips: ${_myTrips.length} viajes');
      
      if (_myTrips.isNotEmpty) {
        for (var trip in _myTrips) {
          print('  Viaje ${trip.id}: ${trip.status}, ${trip.passengers.length} pasajeros');
          for (var p in trip.passengers) {
            print('    - ${p.user.firstName}: ${p.status}');
          }
        }
      }
      
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString()
        .replaceAll('HttpException: ', '')
        .replaceAll('type \'String\' is not a subtype of type \'Map<String, dynamic>\'', 'Error de formato de datos');
      print('ERROR fetchMyTrips: $_errorMessage');
      print('Stack: ${e}');
      _myTrips = [];
      notifyListeners();
    }
  }

  // --- ¡NUEVA FUNCIÓN! ---
  Future<bool> bookTrip(String tripId) async {
    if (_token == null) return false;
    _setLoading(true);
    try {
      await _apiService.post('trips/$tripId/book', _token!, {});
      // Después de reservar, actualizamos la lista de "mis viajes"
      await fetchMyTrips();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('HttpException: ', '');
      _setLoading(false);
      return false;
    }
  }

  // Obtener detalles de un viaje por ID (incluye pasajeros)
  Future<Trip?> fetchTripById(String tripId) async {
    if (_token == null) return null;
    try {
      final data = await _apiService.get('trips/$tripId', _token!);
      return Trip.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('HttpException: ', '');
      return null;
    }
  }

  // Conductor acepta/rechaza solicitud
  Future<bool> manageBooking({required String tripId, required String passengerId, required String status}) async {
    if (_token == null) return false;
    _setLoading(true);
    try {
      await _apiService.put('trips/$tripId/bookings/$passengerId', _token!, {'status': status});
      await fetchMyTrips();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('HttpException: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createTrip(Map<String, dynamic> tripData) async {
    if (_token == null) return false;
    _setLoading(true);
    _errorMessage = '';
    
    try {
      print('createTrip: Enviando datos...');
      final createdTripData = await _apiService.post('trips', _token!, tripData);
      print('createTrip: Respuesta recibida');
      
      final newTrip = Trip.fromJson(createdTripData);
      print('createTrip: Viaje creado con ID: ${newTrip.id}');
      print('createTrip: Status: ${newTrip.status}');
      print('createTrip: Pasajeros: ${newTrip.passengers.length}');

      // Actualizar myTrips inmediatamente agregando el nuevo viaje
      _myTrips.insert(0, newTrip);
      notifyListeners();
      
      // Luego actualizar desde el servidor
      print('createTrip: Actualizando listas...');
      await fetchMyTrips();
      await fetchAvailableTrips();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString()
        .replaceAll('HttpException: ', '')
        .replaceAll('SocketException: ', '')
        .replaceAll('Exception: ', '');
      print('createTrip ERROR: $_errorMessage');
      _setLoading(false);
      return false;
    }
  }

  // --- NUEVAS FUNCIONES PARA GESTIÓN DE VIAJES ---
  
  // Iniciar viaje (conductor)
  Future<bool> startTrip(String tripId) async {
    if (_token == null) return false;
    _setLoading(true);
    _errorMessage = '';
    
    try {
      print('startTrip: Iniciando viaje $tripId...');
      await _apiService.put('trips/$tripId/start', _token!, {});
      print('startTrip: Viaje iniciado exitosamente');
      
      // Actualizar lista de mis viajes
      await fetchMyTrips();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString()
        .replaceAll('HttpException: ', '')
        .replaceAll('Exception: ', '');
      print('startTrip ERROR: $_errorMessage');
      _setLoading(false);
      return false;
    }
  }

  // Cancelar viaje (conductor)
  Future<bool> cancelTrip(String tripId) async {
    if (_token == null) return false;
    _setLoading(true);
    _errorMessage = '';
    
    try {
      print('cancelTrip: Cancelando viaje $tripId...');
      await _apiService.delete('trips/$tripId/cancel', _token!);
      print('cancelTrip: Viaje cancelado exitosamente');
      
      // Actualizar lista de mis viajes y viajes disponibles
      await fetchMyTrips();
      await fetchAvailableTrips();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString()
        .replaceAll('HttpException: ', '')
        .replaceAll('Exception: ', '');
      print('cancelTrip ERROR: $_errorMessage');
      _setLoading(false);
      return false;
    }
  }

  // Salir del viaje (pasajero)
  Future<bool> leaveTrip(String tripId) async {
    if (_token == null) return false;
    _setLoading(true);
    _errorMessage = '';
    
    try {
      print('leaveTrip: Saliendo del viaje $tripId...');
      await _apiService.delete('trips/$tripId/leave', _token!);
      print('leaveTrip: Saliste del viaje exitosamente');
      
      // Actualizar lista de mis viajes
      await fetchMyTrips();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString()
        .replaceAll('HttpException: ', '')
        .replaceAll('Exception: ', '');
      print('leaveTrip ERROR: $_errorMessage');
      _setLoading(false);
      return false;
    }
  }

  // Finalizar viaje (conductor)
  Future<bool> completeTrip(String tripId) async {
    if (_token == null) return false;
    _setLoading(true);
    _errorMessage = '';
    
    try {
      print('completeTrip: Finalizando viaje $tripId...');
      await _apiService.put('trips/$tripId/complete', _token!, {});
      print('completeTrip: Viaje finalizado exitosamente');
      
      // Actualizar lista de mis viajes
      await fetchMyTrips();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString()
        .replaceAll('HttpException: ', '')
        .replaceAll('Exception: ', '');
      print('completeTrip ERROR: $_errorMessage');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}