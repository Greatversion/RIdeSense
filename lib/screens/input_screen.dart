import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:risesense_lite/screens/map_screen.dart';
import 'package:risesense_lite/services/provider.dart';
// import 'package:risesense_lite/screens/map_display_screen.dart';
// import 'package:risesense_lite/services/location_provider.dart';

class LocationInputScreen extends StatefulWidget {
  const LocationInputScreen({super.key});

  @override
  _LocationInputScreenState createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends State<LocationInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch current location on screen load
    Provider.of<LocationProvider>(context, listen: false).fetchCurrentLocation();
  }

  /// Submit the entered location and navigate to the MapDisplayScreen
  void _submitLocation() {
    if (_formKey.currentState!.validate()) {
      String location = _locationController.text.trim();
      Navigator.pushNamed(
        context,
        MapDisplayScreen.routeName,
        arguments: location,
      );
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 75, 255),
        title: Text(
          'Enter Your Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Type here...',
                    labelStyle: TextStyle(
                      color: const Color.fromARGB(255, 62, 62, 62),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                    hintText: 'Enter city name, address, or coordinates',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                    prefixIcon: Icon(Icons.location_on, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.black)),
                    onPressed: _submitLocation,
                    child: Text(
                      'Show on Map',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 35),
                // Display current location or loading indicator
                if (locationProvider.isFetchingLocation)
                  Center(child: CircularProgressIndicator())
                else if (locationProvider.locationErrorMessage.isNotEmpty)
                  Text(locationProvider.locationErrorMessage, style: TextStyle(color: Colors.red))
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(4, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromARGB(48, 158, 158, 158),
                        width: 2,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GoogleMap(
                        markers: {
                          if (locationProvider.currentLatLng != null)
                            Marker(
                              markerId: MarkerId('initial-location'),
                              position: locationProvider.currentLatLng!,
                              infoWindow: InfoWindow(title: 'Your Location'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                            ),
                        },
                        mapType: locationProvider.currentMapType,
                        initialCameraPosition: CameraPosition(
                          target: locationProvider.currentLatLng ?? LatLng(37.7749, -122.4194),
                          zoom: 12.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          if (locationProvider.currentLatLng != null) {
                            controller.animateCamera(
                              CameraUpdate.newLatLngZoom(locationProvider.currentLatLng!, 14),
                            );
                          }
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                    ),
                  ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
