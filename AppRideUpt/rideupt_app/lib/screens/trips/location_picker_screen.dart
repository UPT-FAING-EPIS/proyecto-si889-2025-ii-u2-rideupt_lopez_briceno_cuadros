import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rideupt_app/models/trip.dart';
import 'dart:math' as math;

class LocationPickerScreen extends StatefulWidget {
  final LocationPoint? origin; // Origen (si se proporciona)
  final bool isSelectingDestination; // Si estamos seleccionando destino

  const LocationPickerScreen({
    super.key,
    this.origin,
    this.isSelectingDestination = false,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  LatLng _initialPosition = const LatLng(-12.046374, -77.042793); // Lima, Perú como default
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (widget.origin != null) {
      // Si hay origen, centrar el mapa en el origen
      setState(() {
        _initialPosition = widget.origin!.coordinates;
        _addOriginMarker();
      });
    } else {
      // Si no hay origen, obtener ubicación actual
      await _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Los permisos de ubicación están permanentemente denegados.');
    } 

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
    
    // Mover cámara a la posición actual
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_initialPosition),
    );
  }

  void _addOriginMarker() {
    if (widget.origin == null) return;
    
    _markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: widget.origin!.coordinates,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Origen',
          snippet: widget.origin!.name,
        ),
      ),
    );
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
      
      // Limpiar marcadores previos del destino
      _markers.removeWhere((marker) => marker.markerId.value == 'destination');
      
      // Agregar marcador del destino
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'Destino',
            snippet: 'Ubicación seleccionada',
          ),
        ),
      );

      // Si hay origen, dibujar ruta y calcular distancia
      if (widget.origin != null) {
        _drawRoute();
        _calculateDistance();
      }
    });
  }

  void _drawRoute() {
    if (widget.origin == null || _pickedLocation == null) return;

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [widget.origin!.coordinates, _pickedLocation!],
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );

    // Ajustar la cámara para mostrar ambos puntos
    _fitBounds();
  }

  void _fitBounds() {
    if (widget.origin == null || _pickedLocation == null || _mapController == null) return;

    final origin = widget.origin!.coordinates;
    final destination = _pickedLocation!;

    double south = math.min(origin.latitude, destination.latitude);
    double north = math.max(origin.latitude, destination.latitude);
    double west = math.min(origin.longitude, destination.longitude);
    double east = math.max(origin.longitude, destination.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100), // 100 pixels de padding
    );
  }

  double _calculateDistanceInKm(LatLng origin, LatLng destination) {
    const double earthRadius = 6371; // Radio de la Tierra en km

    double lat1 = origin.latitude * math.pi / 180;
    double lat2 = destination.latitude * math.pi / 180;
    double deltaLat = (destination.latitude - origin.latitude) * math.pi / 180;
    double deltaLng = (destination.longitude - origin.longitude) * math.pi / 180;

    double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
        math.sin(deltaLng / 2) * math.sin(deltaLng / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  void _calculateDistance() {
    if (widget.origin == null || _pickedLocation == null) return;

    setState(() {
      _distanceKm = _calculateDistanceInKm(
        widget.origin!.coordinates,
        _pickedLocation!,
      );
    });
  }
  
  void _confirmSelection() async {
    if (_pickedLocation == null) return;
    
    // Obtener nombre de la calle (Geocoding Inverso)
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
      _pickedLocation!.latitude,
      _pickedLocation!.longitude,
    );
    
    String locationName = 'Ubicación seleccionada';
    if(placemarks.isNotEmpty) {
      final place = placemarks.first;
      locationName = '${place.street ?? 'Calle'}, ${place.locality ?? 'Lima'}';
    }

    final locationPoint = LocationPoint(name: locationName, coordinates: _pickedLocation!);
    Navigator.of(context).pop(locationPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelectingDestination ? 'Selecciona el Destino' : 'Selecciona una Ubicación'),
        backgroundColor: Colors.indigo,
        actions: [
          if (_pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmSelection,
              tooltip: 'Confirmar ubicación',
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (widget.origin != null && _pickedLocation != null) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _fitBounds();
                });
              }
            },
            onTap: _selectLocation,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
          ),
          
          // Card de información en la parte superior
          if (widget.origin != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.my_location, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Origen: ${widget.origin!.name}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (_distanceKm != null) ...[
                        const Divider(height: 16),
                        Row(
                          children: [
                            Icon(Icons.straighten, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Distancia: ${_distanceKm!.toStringAsFixed(2)} km',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // Instrucción en la parte inferior
          if (_pickedLocation == null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.indigo,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isSelectingDestination
                              ? 'Toca en el mapa para seleccionar tu destino'
                              : 'Toca en el mapa para seleccionar una ubicación',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Card de confirmación cuando se selecciona un punto
          if (_pickedLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.green,
                child: InkWell(
                  onTap: _confirmSelection,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          _distanceKm != null
                              ? 'Confirmar Destino (${_distanceKm!.toStringAsFixed(2)} km)'
                              : 'Confirmar Ubicación',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
