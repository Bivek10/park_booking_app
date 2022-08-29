import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkInMap extends StatefulWidget {
  const ParkInMap({Key key}) : super(key: key);

  @override
  State<ParkInMap> createState() => _ParkInMapState();
}

class _ParkInMapState extends State<ParkInMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        buildingsEnabled: false,
        onMapCreated: (GoogleMapController controller) {},
        // markers: markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            double.parse("10"),
            double.parse("10"),
          ),
          zoom: 15,
        ),
        onTap: (LatLng) {},
      ),
    );
  }
}
