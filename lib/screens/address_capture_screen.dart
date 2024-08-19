import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class DeliverooColors {
  static const Color primary = Color(0xFF00CCBC);
  static const Color secondary = Color(0xFF2E3333);
  static const Color background = Color(0xFFF9FAFA);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
}

class AddressCaptureScreen extends StatefulWidget {
  @override
  _AddressCaptureScreenState createState() => _AddressCaptureScreenState();
}

class _AddressCaptureScreenState extends State<AddressCaptureScreen> with WidgetsBindingObserver {
  final FirestoreService _firestoreService = FirestoreService();
  MapController _mapController = MapController();
  LatLng? _currentPosition;
  String _currentAddress = "";
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool userEnabledLocation = await _askUserToEnableLocation();
        if (!userEnabledLocation) {
          throw Exception('Location services are required for this app.');
        }
        return; // The app will retry when it resumes
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      } 

      await _getCurrentLocation();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<bool> _askUserToEnableLocation() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Location services are disabled. Would you like to enable them?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop(true);
                await Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5)
      );
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      
      await _getAddressFromLatLng();
    } on TimeoutException {
      setState(() {
        _errorMessage = "Location request timed out. Please try again.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error getting location: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.street}, ${place.subLocality}, "
              "${place.locality}, ${place.postalCode}, ${place.country}";
        });
      } else {
        setState(() {
          _currentAddress = "Address not found";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Error retrieving address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [DeliverooColors.primary, DeliverooColors.primary.withOpacity(0.8)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingWidget()
              : _errorMessage.isNotEmpty
                  ? _buildErrorWidget()
                  : _buildContentWidget(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Getting your location...',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.white),
          SizedBox(height: 16),
          Text(
            _errorMessage,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(color: Colors.white, fontSize: 18),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _checkLocationPermission,
            child: Text('Retry', style: GoogleFonts.poppins(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              foregroundColor: DeliverooColors.primary,
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Confirm Your Address',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      Expanded(
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DeliverooColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? LatLng(0, 0),
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _currentPosition!,
                        child: Icon(
                          Icons.location_on,
                          color: DeliverooColors.primary,
                          size: 40.0,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: DeliverooColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your current address:',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: DeliverooColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                _currentAddress,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: 16, color: DeliverooColors.textDark),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Confirm Address',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: DeliverooColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () async {
    if (_currentPosition != null) {
      try {
        await _firestoreService.saveUserAddress(
          AuthService().currentUser!.uid,
          _currentAddress,
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving address: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save address. Please try again.')),
      );
    }
  },

              ),
            ],
          ),
        ),
      ],
    );
  }
}