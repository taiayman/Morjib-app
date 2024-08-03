import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static const List<String> majorCities = [
  'Casablanca', 'Rabat', 'Marrakech', 'Fes', 'Tanger',
  'Agadir', 'Meknes', 'Oujda', 'Kenitra', 'Tetouan',
  'Safi', 'Mohammedia', 'Khouribga', 'El Jadida', 'Beni Mellal',
  'Nador', 'Taza', 'Settat'
];

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, handle this case (maybe show a dialog to the user)
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle this case
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle this case
      return false;
    } 

    // Permissions are granted
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5)
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  Future<String> getCurrentCity() async {
    if (!await requestLocationPermission()) {
      return 'Casablanca'; // Default to Casablanca if permission is not granted
    }

    try {
      Position? position = await getCurrentPosition();
      if (position == null) {
        return 'Casablanca'; // Default to Casablanca if position can't be determined
      }
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        String? city = placemarks[0].locality;
        return getNearestMajorCity(city);
      }
    } catch (e) {
      print('Error getting location: $e');
    }
    
    return 'Casablanca'; // Default to Casablanca if we can't get the location
  }

  String getNearestMajorCity(String? currentCity) {
    if (currentCity == null || !majorCities.contains(currentCity)) {
      // If the current city is not in our list, find the nearest major city
      // This is a simplified version. In a real app, you'd use coordinates to find the actual nearest city
      return majorCities.first;
    }
    return currentCity;
  }

  Future<List<String>> getNearbyMajorCities() async {
    String currentCity = await getCurrentCity();
    // This is a simplified version. In a real app, you'd return a list of cities
    // sorted by their distance from the current city
    return majorCities.where((city) => city != currentCity).toList();
  }

  Future<Map<String, double>> getLatLngForCity(String cityName) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        return {
          'latitude': locations.first.latitude,
          'longitude': locations.first.longitude,
        };
      }
    } catch (e) {
      print('Error getting coordinates for $cityName: $e');
    }
    return {'latitude': 0, 'longitude': 0}; // Default coordinates if not found
  }

  Future<double> getDistanceBetweenCities(String city1, String city2) async {
    Map<String, double> coords1 = await getLatLngForCity(city1);
    Map<String, double> coords2 = await getLatLngForCity(city2);

    return Geolocator.distanceBetween(
      coords1['latitude']!,
      coords1['longitude']!,
      coords2['latitude']!,
      coords2['longitude']!,
    ) / 1000; // Convert meters to kilometers
  }
}