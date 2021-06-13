import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map_location/flutter_map_location.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.amber,
        ).copyWith(
          secondary: Colors.amber,
        ),
        textTheme: const TextTheme(bodyText2: TextStyle(color: Colors.purple)),
      ),
      title: "Test",
      home: MapApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapApp extends StatefulWidget {
  @override
  _MapAppState createState() => new _MapAppState();
}

class _MapAppState extends State<MapApp> {
  String _title = 'アルカロ';
  final myMeterController = TextEditingController();
  final myCalController = TextEditingController();
  double radius = 100;

  final MapController mapController = MapController();
  final List<Marker> userLocationMarkers = <Marker>[];

  LocationData locationData;
  Location location = new Location();

  @override
  void initstate() {
    super.initState();
    preLoc();
    getLoc();
  }

  Future<void> preLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<LatLng> getLoc() async {
    locationData = await location.getLocation();
    print("location is... ${locationData.latitude}");
    return LatLng(locationData.latitude, locationData.longitude);
  }

  @override
  void dispose() {
    myMeterController.dispose();
    myCalController.dispose();
    super.dispose();
  }

  void adaptMeter(BuildContext context) {
    setState(() {
      radius = double.parse(myMeterController.text);
      double kcal = radius * 48 / 1000;
      myCalController.text = kcal.toStringAsFixed(2);
    });
  }

  void adaptKcal(BuildContext context) {
    setState(() {
      double kcal = double.parse(myCalController.text);
      radius = kcal * 1000 / 48;
      myMeterController.text = radius.round().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    FutureBuilder mapSection = FutureBuilder<LatLng>(
        future: getLoc(),
        builder: (context, AsyncSnapshot<LatLng> snapshot) {
          if (snapshot.hasData) {
            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                plugins: <MapPlugin>[
                  LocationPlugin(),
                ],
                center: snapshot.data,
                zoom: 14.0,
              ),
              layers: [
                //背景地図読み込み (Maptiler)
                TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                // サークルマーカー設定
                CircleLayerOptions(
                  circles: [
                    // サークルマーカー1設定
                    CircleMarker(
                      color: Colors.yellow.withOpacity(0.7),
                      radius: radius,
                      borderColor: Colors.white.withOpacity(0.9),
                      borderStrokeWidth: 2,
                      point: snapshot.data,
                      useRadiusInMeter: true,
                    ),
                  ],
                ),

                MarkerLayerOptions(markers: userLocationMarkers),
                LocationOptions(
                  markers: userLocationMarkers,
                  onLocationUpdate: (LatLngData ld) {
                    print('Location updated: ${ld?.location}');
                  },
                  onLocationRequested: (LatLngData ld) {
                    if (ld == null || ld.location == null) {
                      return;
                    }
                    mapController?.move(ld.location, 16.0);
                  },
                  buttonBuilder: (BuildContext context,
                      ValueNotifier<LocationServiceStatus> status,
                      Function onPressed) {
                    return Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: 16.0, right: 16.0),
                        child: FloatingActionButton(
                            child:
                                ValueListenableBuilder<LocationServiceStatus>(
                                    valueListenable: status,
                                    builder: (BuildContext context,
                                        LocationServiceStatus value,
                                        Widget child) {
                                      switch (value) {
                                        case LocationServiceStatus.disabled:
                                        case LocationServiceStatus
                                            .permissionDenied:
                                        case LocationServiceStatus.unsubscribed:
                                          return const Icon(
                                            Icons.location_disabled,
                                            color: Colors.white,
                                          );
                                          break;
                                        default:
                                          return const Icon(
                                            Icons.location_searching,
                                            color: Colors.white,
                                          );
                                          break;
                                      }
                                    }),
                            onPressed: () => onPressed()),
                      ),
                    );
                  },
                ),
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        });

    Widget inputMeterSection = Flexible(
        child: TextField(
      decoration: new InputDecoration(
          labelText: "歩く距離(メートル)",
          fillColor: Colors.grey[50],
          filled: true,
          hintText: "歩く距離を入力"),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: myMeterController,
      autofocus: true,
    ));

    Widget inputCalSection = Flexible(
        child: TextField(
      decoration: new InputDecoration(
          labelText: "消費カロリー(kcal)",
          fillColor: Colors.grey[50],
          filled: true,
          hintText: "消費カロリーを入力"),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: myCalController,
    ));

    Widget circleButton = OutlinedButton(
      onPressed: () {
        adaptMeter(context);
      },
      child: Text('距離から設定'),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    );

    Widget calButton = OutlinedButton(
      onPressed: () {
        adaptKcal(context);
      },
      child: Text('消費カロリーから設定'),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(
              fontStyle: FontStyle.italic, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: <Widget>[
          mapSection,
          Column(children: [
            Row(children: [
              inputMeterSection,
              inputCalSection,
            ]),
            Row(
              children: [
                Expanded(child: circleButton),
                Expanded(child: calButton),
              ],
            ),
          ])
        ],
      ),
    );
  }
}
