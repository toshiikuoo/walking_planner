//参照元
// https://qiita.com/dayjournal/items/4b9f8f8fbdc233abacbf

import 'package:flutter/material.dart';
// flutter_mapパッケージ追加
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

void main() {
  runApp(MapApp());
}

class MapApp extends StatefulWidget {
  @override
  _MapAppState createState() => new _MapAppState();
}

class _MapAppState extends State<MapApp> {
  String _title = 'map_app';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'map_app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        // flutter_map設定
        body: FlutterMap(
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
        ),
      ),
    );
  }
}