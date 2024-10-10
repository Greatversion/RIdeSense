import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {
  Marker? searchedLocationMarker;
  Marker? currentLocationMarker;
  bool isLoading = true;
  MapType currentMapType = MapType.normal;
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  String _locationErrorMessage = '';
  LatLng? _currentLatLng;

  Position? get currentPosition => _currentPosition;
  bool get isFetchingLocation => _isFetchingLocation;
  String get locationErrorMessage => _locationErrorMessage;
  LatLng? get currentLatLng => _currentLatLng;

  LatLng initialPosition =
      LatLng(37.7749, -122.4194); // Default to San Francisco

  /// Sets a marker for the entered location after geocoding
  Future<void> setMarkerForLocation(String location) async {
    try {
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        LatLng latLng = LatLng(loc.latitude, loc.longitude);

        searchedLocationMarker = Marker(
          markerId: MarkerId('searched-location'),
          position: latLng,
          infoWindow: InfoWindow(title: 'Searched Location'),
        );

        notifyListeners(); // Notify listeners of changes
      } else {
        throw Exception('No locations found for the entered query.');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching location: $e');
    }
  }

  /// Fetches and sets the user's current location
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    currentLocationMarker = Marker(
      markerId: MarkerId('current-location'),
      position: currentLatLng,
      infoWindow:
          InfoWindow(title: 'Current Location', snippet: 'Current Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    isLoading = false; // Set loading to false after fetching location
    notifyListeners(); // Notify listeners of changes

    // Move camera to current location if no searched location
    if (searchedLocationMarker == null) {
      // Here you would handle moving the camera in your UI component
    }
  }

  /// Toggles between different map types
  void toggleMapType() {
    if (currentMapType == MapType.normal) {
      currentMapType = MapType.satellite;
    } else if (currentMapType == MapType.satellite) {
      currentMapType = MapType.terrain;
    } else if (currentMapType == MapType.terrain) {
      currentMapType = MapType.hybrid;
    } else {
      currentMapType = MapType.normal;
    }
    notifyListeners(); // Notify listeners of changes
  }

  /// Fetches the current location and updates the state.
  Future<void> fetchCurrentLocation() async {
    _isFetchingLocation = true;
    notifyListeners();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isFetchingLocation = false;
      _locationErrorMessage = 'Location services are disabled.';
      notifyListeners();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isFetchingLocation = false;
        _locationErrorMessage = 'Location permission denied.';
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _isFetchingLocation = false;
      _locationErrorMessage =
          'Location permissions are permanently denied. Please enable them in settings.';
      notifyListeners();
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _currentLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _locationErrorMessage = ''; // Clear any previous errors
    } catch (e) {
      _locationErrorMessage = 'Error fetching location: $e';
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
    }
  }
}
