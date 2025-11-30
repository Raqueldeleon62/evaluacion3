import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'panelusu.dart';


class Mapa extends StatelessWidget {
  const Mapa({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final double latitud = args['latitud'];
    final double longitud = args['longitud'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Asistencia'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(latitud, longitud),
          minZoom: 5.0,
          maxZoom: 25,
          zoom: 18.0,
        ),
        children: [
          TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(point: LatLng(latitud, longitud),
            width: 40,
            height: 40,
            builder: (context) {
              return Container(
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              );
            },
            )
          ],
        )
        ]

      )
    );
  }
}
