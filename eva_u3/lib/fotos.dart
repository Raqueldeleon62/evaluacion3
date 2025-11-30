import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:convert';

class FotoPage extends StatefulWidget {
  final int identrega;
  const FotoPage({super.key, required this.identrega});

  @override
  _FotoPageState createState() => _FotoPageState();
}

class _FotoPageState extends State<FotoPage> {
  Uint8List? _imageBytes;
  XFile? _pickedFile;
  final picker = ImagePicker();
  int? idubi;

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _pickedFile = pickedFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto tomada correctamente")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se tomó ninguna foto")),
      );
    }
  }

  Future<void> subirFotoYUbicacion() async {
    if (_pickedFile == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero toma una foto")),
      );
      return;
    }

    // Obtener ubicación
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/ubicaciones'),
    );

    request.fields['latitud'] = pos.latitude.toString();
    request.fields['longitud'] = pos.longitude.toString();
    request.fields['ubi_gps'] = "GPS registrado";

    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        _imageBytes!,
        filename: _pickedFile!.name,
      ),
    );

    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var data = json.decode(respStr);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto y ubicación registradas correctamente"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, {
        'id_ubi': data['id_ubi'],
        'latitud': pos.latitude,
        'longitud': pos.longitude,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al registrar foto y ubicación"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget mostrarImagenLocal() {
    if (_imageBytes == null) return const Text("No hay imagen seleccionada");
    return Image.memory(_imageBytes!, width: 300);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 161, 13, 13), Color.fromARGB(255, 210, 56, 25)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Subir Foto y Ubicación',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD97B66), Color(0xFFF2E5D5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    mostrarImagenLocal(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: getImage,
                      child: const Text("Tomar Foto"),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: subirFotoYUbicacion,
                child: const Text("Subir Foto y Registrar Ubicación"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
