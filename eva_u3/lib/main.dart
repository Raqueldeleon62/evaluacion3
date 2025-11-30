import 'package:eva_u3/panelad.dart';
import 'package:eva_u3/panelusu.dart';
import 'package:eva_u3/regostro.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'mapa.dart';
import 'regostro.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor App',
      initialRoute: '/',
      routes: {
        '/': (context) => Iniciosesion(),
        '/admin': (context) => Panelctrl(),
        '/paquetes/entregas': (context) =>Entregas(),
        '/mapa': (context) => Mapa(),
        '/registro': (context) => Registro(),
      },
    );
  }
}
