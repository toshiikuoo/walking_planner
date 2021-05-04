//参照元
// https://qiita.com/dayjournal/items/4b9f8f8fbdc233abacbf

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// flutter_mapパッケージ追加
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

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

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  void testAlert(BuildContext context) {
    var alert = AlertDialog(
      title: Text("Test"),
      content: Text(myController.text),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget mapSection = FlutterMap(
      // マップ表示設定
      options: MapOptions(
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
              radius: 1000,
              borderColor: Colors.white.withOpacity(0.9),
              borderStrokeWidth: 13,
              point: LatLng(35.681, 139.760),
              useRadiusInMeter: true,
            ),
            // サークルマーカー2設定

          ],
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            testAlert(context);
          },
          child: Icon(Icons.text_fields),
        ),

      );

  }
}



