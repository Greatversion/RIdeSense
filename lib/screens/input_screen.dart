import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:risesense_lite/screens/map_display_screen.dart';
import 'package:risesense_lite/screens/map_screen.dart';

class LocationInputScreen extends StatefulWidget {
  const LocationInputScreen({super.key});

  @override
  _LocationInputScreenState createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends State<LocationInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  Position? _currentPosition; // Store the current location
  bool _isFetchingLocation = false; // Flag to show loading indicator
  String _locationErrorMessage = ''; // To store location error message
  LatLng? currentLatLng;
  @override
  void initState() {
    super.initState();

    _checkLocationPermissionAndFetch(); // Request location permission and get location on screen load
    get();
  }

  /// Check location permission and fetch current location
  Future<void> _checkLocationPermissionAndFetch() async {
    setState(() {
      _isFetchingLocation = true; // Start loading indicator
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isFetchingLocation = false;
        _locationErrorMessage = 'Location services are disabled.';
      });
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isFetchingLocation = false;
          _locationErrorMessage = 'Location permission denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isFetchingLocation = false;
        _locationErrorMessage =
            'Location permissions are permanently denied. Please enable them in settings.';
      });
      return;
    }

    // Fetch current location
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _isFetchingLocation = false; // Stop loading indicator
        _locationErrorMessage = ''; // Clear any previous errors
      });
    } catch (e) {
      setState(() {
        _isFetchingLocation = false;
        _locationErrorMessage = 'Error fetching location: $e';
      });
    }
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

  get() async {
    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentLatLng = LatLng(position.latitude, position.longitude);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationController.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      color: const Color.fromARGB(
                          255, 62, 62, 62), // Style for the label text
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                    hintText: 'Enter city name, address, or coordinates',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400, // Style for the hint text
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
                        backgroundColor:
                            WidgetStatePropertyAll<Color>(Colors.black)),
                    onPressed: _submitLocation,
                    child: Text(
                      'Show on Map',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 35),

                // Display current location or loading indicator
                _isFetchingLocation
                    ? Center(child: Center(child: CircularProgressIndicator()))
                    : Container(
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
                              if (currentLatLng !=
                                  null) // Add a marker only if the position is available
                                Marker(
                                  markerId: MarkerId('initial-location'),
                                  position:
                                      currentLatLng!, // Position of the marker (initial position)
                                  infoWindow:
                                      InfoWindow(title: 'Your Location'),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed, // Marker color
                                  ),
                                ),
                            },
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                              target:
                                  currentLatLng ?? LatLng(37.7749, -122.4194),
                              zoom: 12.0,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              controller.animateCamera(
                                CameraUpdate.newLatLngZoom(currentLatLng!, 14),
                              );
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                          ),
                        ),
                      ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
