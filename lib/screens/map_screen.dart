import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:risesense_lite/services/provider.dart';


class MapDisplayScreen extends StatefulWidget {
  static const String routeName = '/mapDisplay';

  const MapDisplayScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapDisplayScreenState createState() => _MapDisplayScreenState();
}

class _MapDisplayScreenState extends State<MapDisplayScreen> {
  GoogleMapController? _mapController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location =
        ModalRoute.of(context)!.settings.arguments as String;
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    locationProvider.setMarkerForLocation(location).catchError((error) {
      _showErrorSnackBar(error.toString());
    });
    
    locationProvider.getCurrentLocation().catchError((error) {
      _showErrorSnackBar(error.toString());
    });
  }

  void _moveCamera(LatLng latLng) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 14),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    Set<Marker> markers = {};
    if (locationProvider.searchedLocationMarker != null) {
      markers.add(locationProvider.searchedLocationMarker!);
    }
    if (locationProvider.currentLocationMarker != null) {
      markers.add(locationProvider.currentLocationMarker!);
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 42, 75, 255),
        title: Text(
          'Map Display',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.map,
              color: Colors.white,
            ),
            onPressed: () {
              locationProvider.toggleMapType();
            },
            tooltip: 'Change Map Type',
          ),
        ],
      ),
      body: locationProvider.isLoading && locationProvider.searchedLocationMarker == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: locationProvider.currentMapType,
              initialCameraPosition: CameraPosition(
                target: locationProvider.initialPosition,
                zoom: 12.0,
              ),
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;

                if (locationProvider.searchedLocationMarker != null) {
                  _moveCamera(locationProvider.searchedLocationMarker!.position);
                } else if (locationProvider.currentLocationMarker != null) {
                  _moveCamera(locationProvider.currentLocationMarker!.position);
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
