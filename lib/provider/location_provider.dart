import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

class LocationProvider with ChangeNotifier {
  final Location _location = Location();
  LatLng _currentLocation = LatLng(0, 0);
  List<LatLng> _polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Marker? _currentLocationMarker; // Marker for the user's current location
  Marker? _selectedLocationMarker; // Marker for the selected location
  Timer? _timer;

  LatLng get currentLocation => _currentLocation;
  Set<Polyline> get polylines => _polylines;

  // Combine both markers into a set for display
  Set<Marker> get markers {
    final markers = <Marker>{};
    if (_currentLocationMarker != null) markers.add(_currentLocationMarker!);
    if (_selectedLocationMarker != null) markers.add(_selectedLocationMarker!);
    return markers;
  }

  LocationProvider() {
    _initializeLocationUpdates();
  }

  void _initializeLocationUpdates() async {
    final initialLocation = await _location.getLocation();
    _updateLocation(initialLocation);

    _timer = Timer.periodic(Duration(seconds: 10), (_) async {
      final updatedLocation = await _location.getLocation();
      _updateLocation(updatedLocation);
    });
  }

  void _updateLocation(LocationData currentLocation) {
    LatLng newPosition = LatLng(
      currentLocation.latitude ?? 0.0,
      currentLocation.longitude ?? 0.0,
    );

    _currentLocation = newPosition;
    _polylineCoordinates.add(_currentLocation);

    // Update the marker for the current location
    _currentLocationMarker = Marker(
      markerId: MarkerId('currentLocation'),
      position: _currentLocation,
      infoWindow: InfoWindow(
        title: 'My Current Location',
        snippet: '${_currentLocation.latitude}, ${_currentLocation.longitude}',
      ),
    );

    // Update the polyline
    _polylines = {
      Polyline(
        polylineId: PolylineId('route'),
        points: _polylineCoordinates,
        color: Colors.blue,
        width: 5,
      ),
    };

    notifyListeners();
  }

  void addMarker(LatLng position) {
    // Remove the previous selected marker and add the new one
    _selectedLocationMarker = Marker(
      markerId: MarkerId('selectedLocation'),
      position: position,
      infoWindow: InfoWindow(
        title: 'Selected Location',
        snippet: '${position.latitude}, ${position.longitude}',
      ),
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
