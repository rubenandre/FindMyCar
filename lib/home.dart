import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:android_intent/android_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io' show Platform;

import 'dart:async';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// Instance of Geolocator used by Home()
  Geolocator _geolocator;

  /// Instance of LatLng
  /// n is where the user marked that parked the car
  LatLng _savedPosition;

  /// Controller of Google Maps
  GoogleMapController _controller;

  /// Set of markers
  /// Used to display the marks in the map
  final Set<Marker> _markers = Set();

  @override
  void initState() {
    super.initState();
    _geolocator = Geolocator();
    _checkGps();
    _getInitialLatLong();
  }

  /// Method that load the stored location from shared preferences
  /// It's used shared preferences because it's the most easy way to implement data store and data import
  void _getInitialLatLong() async {
    final prefs = await SharedPreferences.getInstance();
    final double latitude = prefs.getDouble("lat");
    final double longitude = prefs.getDouble("lng");
    if (latitude != null && longitude != null) {
      _savedPosition = LatLng(latitude, longitude);
      _updateMarkers();
    }

    _geolocator
        .getPositionStream(LocationOptions(
            accuracy: LocationAccuracy.best, timeInterval: 1000))
        .listen((position) {
      _controller.moveCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)));
    });
  }

  /// Method that update the set marks (initializing app)
  void _updateMarkers() {
    Marker _m = Marker(
        markerId: MarkerId(_savedPosition.toString()),
        position: _savedPosition);
    setState(() {
      if (_markers.length == 0) {
        _markers.add(_m);
      } else {
        _markers.clear();
        _markers.add(_m);
      }
    });
  }

  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Can't get gurrent location"),
              content:
                  const Text('Please make sure you enable GPS and try again'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    final AndroidIntent intent = new AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');

                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<GeolocationStatus> _checkPermission() async {
    return _geolocator.checkGeolocationPermissionStatus();
  }

  /// Method that get a instance of position from Geolocator
  Future<Position> _getPosition() async {
    GeolocationStatus status = await _checkPermission();
    if (status == GeolocationStatus.granted) {
      return await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(new Duration(seconds: 5));
    }
  }

  /// Method that add park location marker to the map
  void _addMarkerCarLocation() async {
    Position local = await _getPosition();
    try {
      Marker _m = Marker(
          markerId: MarkerId(local.toString()),
          position: LatLng(local.latitude, local.longitude));
      setState(() {
        if (_markers.length == 0) {
          _markers.add(_m);
        } else {
          _markers.clear();
          _markers.add(_m);
        }
      });
      _savedPosition = LatLng(local.latitude, local.longitude);
      _saveData();
    } catch (e) {}
  }

  /// Method that save data to shared preferences
  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("lat", _savedPosition.latitude);
    prefs.setDouble("lng", _savedPosition.longitude);
  }

  /// Method that open google maps with the directions to the local that car is parked
  void _findCar() {
    if (_savedPosition == null) {
      _showMessage("Please save a parking local first",
          "We can't find your car because you do not save it location!");
    } else if (Platform.isAndroid) {
      _openGoogleMaps();
    }
  }

  /// Open google maps app directions
  void _openGoogleMaps() async {
    Position local = await _getPosition();
    double latitude = local.latitude;
    if (local.latitude == _savedPosition.latitude &&
        local.longitude == _savedPosition.longitude) {
      latitude += 0.0000001;
    }
    final AndroidIntent intent = new AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull("https://www.google.com/maps/dir/?api=1&origin=" +
            "$latitude,${local.longitude}" +
            "&destination=" +
            "${_savedPosition.latitude},${_savedPosition.longitude}" +
            "&travelmode=walking"),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  /// Method that show an error message in case that the user does not select any park local
  void _showMessage(title, content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Method trigged when map is full created
  void _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    _getPosition().then((local) => _controller.moveCamera(
        CameraUpdate.newLatLng(LatLng(local.latitude, local.longitude))));
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-9172076661286680~7351896392")
        .then((result) {
      myBanner
        ..load()
        ..show();
    });
    return Scaffold(
        appBar: AppBar(
          title: Text("Find My Car"),
          centerTitle: true,
          backgroundColor: Color(0xFF048BA8),
        ),
        body: Stack(
          children: <Widget>[
            buildMap(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      buildButton(
                        _addMarkerCarLocation,
                        0xFF99C24D,
                        Icon(Icons.add_location, size: 36.0),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      buildButton(_findCar, 0xFF99C24D,
                          Icon(Icons.location_searching, size: 36.0))
                    ],
                  )),
            )
          ],
        ));
  }

  /// Method that build the map
  Widget buildMap() {
    return GoogleMap(
      markers: _markers,
      mapType: MapType.hybrid,
      onMapCreated: _onMapCreated,
      initialCameraPosition:
          CameraPosition(target: LatLng(2.0, -150.0), zoom: 19.5),
    );
  }

  /// Method that build the app buttons (save and locate park)
  Widget buildButton(func, color, icon) {
    return FloatingActionButton(
        onPressed: func,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Color(color),
        child: icon);
  }
}

BannerAd myBanner = BannerAd(
  adUnitId: "ca-app-pub-9172076661286680/3849380054",
  size: AdSize.fullBanner,
);

