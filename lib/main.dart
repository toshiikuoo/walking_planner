//参照元
// https://qiita.com/dayjournal/items/4b9f8f8fbdc233abacbf

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map_location/flutter_map_location.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      home: MapApp(),
    );
  }
}

class MapApp extends StatefulWidget {
  @override
  _MapAppState createState() => new _MapAppState();
}

class _MapAppState extends State<MapApp> {
  String _title = 'map_app';
  final myController = TextEditingController();
  var radius = 100.0;

  final MapController mapController = MapController();
  final List<Marker> userLocationMarkers = <Marker>[];

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  void testAlert(BuildContext context) {
    // var alert = AlertDialog(
    //   title: Text("Test"),
    //   content: Text(myController.text),
    // );
    //
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return alert;
    //     });

    setState(() {
      radius = double.parse(myController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget mapSection = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        plugins: <MapPlugin>[
          LocationPlugin(),
        ],
        center: LatLng(35.681, 139.767),
        zoom: 14.0,
      ),
      layers: [
        //背景地図読み込み (Maptiler)
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']
        ),
        // サークルマーカー設定
        CircleLayerOptions(
          circles: [
            // サークルマーカー1設定
            CircleMarker(
              color: Colors.yellow.withOpacity(0.7),
              radius: radius,
              borderColor: Colors.white.withOpacity(0.9),
              borderStrokeWidth: 2,
              //TODO:円を現在地に書く
              point: LatLng(35.681, 139.760),
              // point: ld?.location,
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
                padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                child: FloatingActionButton(
                    child: ValueListenableBuilder<LocationServiceStatus>(
                        valueListenable: status,
                        builder: (BuildContext context,
                            LocationServiceStatus value, Widget child) {
                          switch (value) {
                            case LocationServiceStatus.disabled:
                            case LocationServiceStatus.permissionDenied:
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

    Widget inputSection = TextField(
      decoration: new InputDecoration(labelText: "Enter your number"),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: myController,
    );



    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        // flutter_map設定
        body: Stack(
          children: [
            mapSection,
            inputSection,],

        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     testAlert(context);
        //   },
        //   child: Icon(Icons.text_fields),
        // ),

      );

  }
}



