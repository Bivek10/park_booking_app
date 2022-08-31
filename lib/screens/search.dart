import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkingapp/lib1/review.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../lib1/admin_login.dart';
import '../lib1/main.dart';
import '../lib1/my_home.dart';
import '../models/place.dart';
import '../services/geolocator_service.dart';
import '../services/marker_service.dart';
import '';

class Search extends StatefulWidget {
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        setState(() {
          user = firebaseUser;
        });
      } else {
        setState(() {
          user = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = Provider.of<Position>(context);
    final placesProvider = Provider.of<Future<List<Place>>>(context);
    final geoService = GeoLocatorService();
    final markerService = MarkerService();

    return FutureProvider(
      create: (context) => placesProvider,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(37, 52, 112, 0.8),
          title: Text(
            "Nearest Parking Area",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminLogin(),
                    ),
                  );
                },
                child: Chip(
                  avatar: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  label: Text(
                    "Admin Login",
                    style: TextStyle(
                      color: Color.fromRGBO(37, 52, 112, 0.8),
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: (currentPosition != null)
            ? Consumer<List<Place>>(
                builder: (_, places, __) {
                  var markers = (places != null)
                      ? markerService.getMarkers(places)
                      : List<Marker>();
                  return (places != null)
                      ? Column(
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height / 2.5,
                              width: MediaQuery.of(context).size.width,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(currentPosition.latitude,
                                        currentPosition.longitude),
                                    zoom: 16.0),
                                zoomGesturesEnabled: true,
                                markers: Set<Marker>.of(markers),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Expanded(
                              child: (places.length > 0)
                                  ? ListView.builder(
                                      itemCount: places.length,
                                      itemBuilder: (context, index) {
                                        return FutureProvider(
                                          create: (context) =>
                                              geoService.getDistance(
                                                  currentPosition.latitude,
                                                  currentPosition.longitude,
                                                  places[index]
                                                      .geometry
                                                      .location
                                                      .lat,
                                                  places[index]
                                                      .geometry
                                                      .location
                                                      .lng),
                                          child: Card(
                                            child: ListTile(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyHomePage(
                                                      title: places[index].name,
                                                    ),
                                                  ),
                                                );
                                              },
                                              title: Text(places[index].name),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 3.0,
                                                  ),
                                                  (places[index].rating != null)
                                                      ? Row(
                                                          children: <Widget>[
                                                            RatingBarIndicator(
                                                              rating:
                                                                  places[index]
                                                                      .rating,
                                                              itemBuilder: (context,
                                                                      index) =>
                                                                  Icon(
                                                                      Icons
                                                                          .star,
                                                                      color: Colors
                                                                          .amber),
                                                              itemCount: 5,
                                                              itemSize: 10.0,
                                                              direction: Axis
                                                                  .horizontal,
                                                            )
                                                          ],
                                                        )
                                                      : Row(),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Consumer<double>(
                                                    builder: (context, meters,
                                                        wiget) {
                                                      return (meters != null)
                                                          ? Text(
                                                              '${places[index].vicinity} \u00b7 ${(meters / 1609).round()} mi')
                                                          : Container();
                                                    },
                                                  ),
                                                  user != null
                                                      ? InkWell(
                                                          onTap: () {
                                                            print(user.email);
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ReviewForm(
                                                                  userid: user
                                                                      .email,
                                                                  parkname:
                                                                      places[index]
                                                                          .name,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Chip(
                                                            label:
                                                                Text("Review"),
                                                            avatar:
                                                                CircleAvatar(
                                                              radius: 20,
                                                              backgroundColor:
                                                                  Colors
                                                                      .orangeAccent,
                                                              child: Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .feedback,
                                                                    size: 10,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                              trailing: IconButton(
                                                icon: Icon(Icons.directions),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                onPressed: () {
                                                  _launchMapsUrl(
                                                      places[index]
                                                          .geometry
                                                          .location
                                                          .lat,
                                                      places[index]
                                                          .geometry
                                                          .location
                                                          .lng);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                  : Center(
                                      child: Text('No Parking Found Nearby'),
                                    ),
                            )
                          ],
                        )
                      : Center(child: CircularProgressIndicator());
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  void _launchMapsUrl(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
