import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  MapsScreen({super.key});

  static final initialPosition = LatLng(15.987791841062283, 120.5731957969313);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;

  Set<Marker> markers = {
    Marker(
      markerId: MarkerId('01'),
      position: MapsScreen.initialPosition,
      infoWindow: InfoWindow(title: 'My Initial Location'),
    ),
  };

  void setToLocation(LatLng position) {
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId('$position'),
        position: position,
        infoWindow: InfoWindow(title: 'Pinned Location'),

        // icon: BitmapDescriptor.
      ),
    );
    CameraPosition cameraPosition = CameraPosition(target: position, zoom: 15);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
  }

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
    //current location
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((position) {
      setToLocation(LatLng(position.latitude, position.longitude));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: CameraPosition(
            target: MapsScreen.initialPosition,
            zoom: 13,
            // tilt: 50,
          ),
          markers: markers,
          onTap: (position) {
            print(position);
            setToLocation(position);
          },
          onMapCreated: (controller) {
            mapController = controller;
          },
        ),
      ),
    );
  }
}
