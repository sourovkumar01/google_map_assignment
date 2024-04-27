import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Position? currentPosition;
  final CameraPosition gaza = const CameraPosition(
    bearing: 192.8334901395799,
    zoom: 10,
    tilt: 59.440717697143555,
    target: LatLng(31.503868877387333, 34.46666549964362),
  );
  LatLng? currentLatLn;
  List<LatLng> points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text('Real Time Location Tracker'),
      ),
      body: googleMap,
    );
  }

  GoogleMap get googleMap {
    return GoogleMap(

      mapType: MapType.terrain,
      markers: {
        Marker(
            markerId: const MarkerId('current position'),
            infoWindow: InfoWindow(
                title: 'My Current Location',
                snippet:
                    '${currentLatLn?.latitude.toStringAsFixed(5)},${currentLatLn?.longitude.toStringAsFixed(5)}'),
            position: currentLatLn ??
                const LatLng(31.503868877387333, 34.46666549964362))
      },
      polylines: {
        Polyline(
            polylineId: PolylineId(points.length.toString()),
            points: points,
            color: Colors.blue)
      },
      initialCameraPosition: gaza,
      onMapCreated: (GoogleMapController googleMapController) {
        _controller.complete(googleMapController);
        getCurrentLocation();
      },
    );
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      //if(!serviceEnabled)  return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Geolocator.getPositionStream(
        locationSettings:  AndroidSettings(
          intervalDuration:const Duration(seconds:10),
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
    )).listen((Position? position) {
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
      setCurrentPosition(position!);
      addPolyLinPoints(position);
      changeMarkerPosition(position);
      goToCurrentLocation();
    });

    return;
  }

  void setCurrentPosition(Position p) {
    currentPosition = p;
    setState(() {});
  }

  void changeMarkerPosition(Position p) {
    currentLatLn = LatLng(p.latitude, p.longitude);
    setState(() {});
  }

  void addPolyLinPoints(Position p) {
    points.add(LatLng(p.latitude, p.longitude));
  }

  Future<void> goToCurrentLocation() async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 192.8334901395799,
          zoom: 16,
          tilt: 59.440717697143555,
          target: LatLng(currentPosition?.latitude ?? 31.503868877387333,
              currentPosition?.longitude ?? 34.46666549964362),
        ),
      ),
    );
  }
}
