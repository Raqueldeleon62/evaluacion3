import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'fotos.dart';
import 'package:geolocator/geolocator.dart';

class EntregasUlista extends StatefulWidget {
  final int userId;
  const EntregasUlista({super.key, required this.userId});

  @override
  _EntregasUlistaState createState() => _EntregasUlistaState();
}

class _EntregasUlistaState extends State<EntregasUlista> {
  List<dynamic> entregas = [];

  Future<void> cargarpaquetes() async {
    final url = Uri.parse('http://127.0.0.1:8000/paquetes/asignados/${widget.userId}');
    final response = await http.get(url);

    if (response.statusCode == 200){
      setState(() {
        entregas = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al caragar productos: ${response.statusCode}'),
      ),
      );
    }
  }
  @override
  void initState(){
    super.initState();
    cargarpaquetes();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: const Size.fromHeight(60),
      
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 161, 13, 13),
            Color.fromARGB(255, 210, 56, 25),
          ], //azul oscuro a medio
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Lista de entregas asignadas',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
             Color(0xFFD97B66),
            Color(0xFFF2E5D5),
          ], //azul claro a azul oscuro
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: entregas.length,
          itemBuilder: (context, index){
            final entrega = entregas[index];
            return Card (
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 220, 171, 103),
                  child: Text(entrega['id_pac'].toString(),
                  style: const TextStyle(color: Colors.black),
                  ),
                ),
                title: Text(
                  entrega['nombre'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Descripción: ${entrega['descripcion']}'),
                    Text('Dirección: ${entrega['direc']}'),
                    Text('Estatus: ${entrega['estatus']}'),
                    Text('Agente(Id): ${entrega['id_usr']}'),
                  ],
                ),
                // Para agregrar iconos de modificar y editar
                trailing: Row(mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_rounded, color: Color.fromARGB(255, 137, 58, 27)),
                    onPressed: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Editarentrega(),
                      settings: RouteSettings(
                        arguments: entrega, 
                      ),),
                      );
                    },
                  ),
                ],
                ),
              ),
              );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pop(context),
      tooltip: 'Volver al formulario',
      child: const Icon(Icons.arrow_back),
      ),
    );
  }
}


class Editarentrega extends StatefulWidget {
  const Editarentrega({super.key});

  @override
  _EditarentregaState createState() => _EditarentregaState();
}

class _EditarentregaState extends State<Editarentrega> {
  Map<String, double>? ubicacion; // latitud y longitud
  int? idubi;
  late Map entrega;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recibir datos de la entrega
    entrega = ModalRoute.of(context)!.settings.arguments as Map;
  }

  Future<void> registrarEntrega() async {
    if (idubi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes tomar foto y registrar ubicación")),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/entrega/'),
    );

    request.fields['id_pac'] = entrega['id_pac'].toString();
    request.fields['id_ubi'] = idubi.toString();

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Entrega registrada correctamente"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      print(respStr);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al registrar entrega"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              begin: Alignment.bottomLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Modificar Producto',
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
            // Parte superior con información (scrollable si crece)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Nombre: ${entrega['nombre']}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Descripción: ${entrega['descripcion']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dirección: ${entrega['direc']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            // Parte inferior con botones
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FotoPage(identrega: entrega['id_pac']),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          idubi = result['id_ubi'];
                          ubicacion = {
                            'latitud': result['latitud'],
                            'longitud': result['longitud'],
                          };
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Foto y ubicación registradas")),
                        );
                      }
                    },
                    child: const Text('Completar entrega'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: idubi != null ? registrarEntrega : null,
                    child: const Text('Registrar entrega'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
