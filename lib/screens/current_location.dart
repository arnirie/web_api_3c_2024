import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({super.key});

  @override
  State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  Position? position;
  geocoding.Location? location;
  TextEditingController address = TextEditingController();

  Future<bool> checkServicePermission() async {
    //checking location service
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location services is disabled. Please enable it in the settings.')),
      );
      return false;
    }
    //check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      //ask for permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permission is denied. Please accept the location permission of the app to continue.'),
          ),
        );
      }
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permission is permanently denied. Please change in the settings to continue.'),
        ),
      );
      return false;
    }
    return true;
  }

  void getCurrentLocation() async {
    if (!await checkServicePermission()) {
      return;
    }
    position = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  void getGeocode() async {
    List<geocoding.Location> locations =
        await geocoding.locationFromAddress(address.text);
    print(locations);
    if (locations.isNotEmpty) {
      setState(() {
        location = locations.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Location'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: getCurrentLocation,
            child: const Text(
              'Get Location',
            ),
          ),
          Text('Lat: ${position?.latitude ?? ''}'),
          Text('Long: ${position?.longitude ?? ''}'),
          TextField(
            controller: address,
          ),
          ElevatedButton(onPressed: getGeocode, child: const Text('GeoCode')),
          Text(
              'GPS: ${location?.latitude ?? ''}, ${location?.longitude ?? ''}'),
        ],
      ),
    );
  }
}
