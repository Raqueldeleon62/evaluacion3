import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

// import 'package:prac8_u3/usuario_form.dart';
import 'dart:convert';

// import 'package:prac8_u3/usuario_list.dart';

///1. Pantalla principal con drawer
///------
class Panelctrl extends StatelessWidget {
  const Panelctrl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menú principal")),
      drawer: MenuLateral(),
      body: Center (child: Text("Bienvenido al gestor de logistica" ,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      ),
    );
  }
}

///-------
///2. Menu lateral (drawer)
///------
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(decoration: BoxDecoration(color: const Color.fromARGB(255, 221, 132, 43)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.account_circle, size: 64, color:Colors.white),
            SizedBox(height: 10),
            Text(
              "Menú de gestor",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        ),
        ListTile(
        leading: Icon(Icons.home),
        title: Text("Inicio"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Panelctrl()),
          );
        },
        ),
        ListTile(
          leading: Icon(Icons.people),
          title: Text("Usuarios"),
          onTap: () {
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => UsuarioList()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.book),
          title: Text("Paquetes"),
          onTap: (){
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => Paquetes()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.comment),
          title: Text("Entregas"),
          onTap: (){
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => EntregasRegistradas()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.comment),
          title: Text("Ubicaciones"),
          onTap: (){
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => UbicacionesLista()),
            );
          },
        ),
      ],
    ),
    );
  }
}

class Paquetes extends StatefulWidget {
  const Paquetes({super.key});

  @override
  _PaquetesState createState() => _PaquetesState();
}

class _PaquetesState extends State<Paquetes> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _usuarioController = TextEditingController();

  Future<LatLng?> obtenerLatLon(String direccion) async {
  final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$direccion&format=json&limit=1");

  final resp = await http.get(url, headers: {
    "User-Agent": "flutter-app"  // Nominatim lo pide
  });

  if (resp.statusCode == 200) {
    final data = jsonDecode(resp.body);
    if (data != null && data.isNotEmpty) {
      final lat = double.parse(data[0]["lat"]);
      final lon = double.parse(data[0]["lon"]);
      return LatLng(lat, lon);
    }
  }
  return null;
  }

  Future<void> agregarpaquete() async{
    final url =Uri.parse('http://localhost:8000/paquetes');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'direc': _direccionController.text,
        'id_usr': int.parse(_usuarioController.text),
      }),
    );
    print("response body: ${response.body}");


    if (response.statusCode == 200 || response.statusCode == 201) {
    final Paquete = jsonDecode(response.body);
    final id = Paquete['id_pac'];
    final nombre = Paquete['nombre'];

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paquete  insertado: $id - $nombre ')),
    );

    _nombreController.clear();
    _descripcionController.clear();
    _direccionController.clear();
    _usuarioController.clear();
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error al insertar el paquete')));
  }


  print(response.statusCode);
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
          begin:Alignment.bottomLeft,
          end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Agregar Paquete',
          style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors:[
          Color(0xFFD97B66),
          Color(0xFFF2E5D5),
          ], //azul claro a azul oscuro
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          ),
        ),
        child: Padding(padding: const EdgeInsets.all(16.0),
        child: Card(elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            TextField(
              controller: _usuarioController,
              decoration: InputDecoration(labelText: 'Agente(ID)'),
            ),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre de paquete'),
            ),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: 'Descripcion'),
            ),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(labelText: 'Dirección'),
            ),
            ElevatedButton(
  onPressed: () async {
    if (_direccionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe una dirección primero")),
      );
      return;
    }

    LatLng? punto = await obtenerLatLon(_direccionController.text);

    if (punto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró la dirección")),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/mapa',
      arguments: {
        'latitud': punto.latitude,
        'longitud': punto.longitude,
      },
    );
  },
  child: Text("Ver mapa"),
),
            SizedBox(height: 20),
            ElevatedButton(onPressed: agregarpaquete, child: Text('Agregar'),
            ),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/paquetes/entregas'),
            child: Text('Ver lista de paquetes'),
            ),
          ],
        ),
        ),
        ),
      ),
    );
  }
}

class Entregas extends StatefulWidget{
  const Entregas({super.key});

  @override
  _EntregasListaState createState() => _EntregasListaState();
} 

class _EntregasListaState extends State<Entregas> {
  List<dynamic> entregas = [];
  
  Future<void> cargarpaquetes() async {
    final url = Uri.parse('http://localhost:8000/paquetes/');
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
            'Lista de paquetes',
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



class UsuarioList extends StatefulWidget {
  const UsuarioList({super.key});

  @override
  _UsuarioListState createState() => _UsuarioListState();
}

class _UsuarioListState extends State<UsuarioList> {
  List<dynamic> usuarios = [];

  Future<void> cargarUsuarios() async {
    final url = Uri.parse('http://localhost:8000/usuario/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        usuarios = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: ${response.statusCode}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 161, 13, 13),
                Color.fromARGB(255, 210, 56, 25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Lista de Usuarios',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD97B66),
              Color(0xFFF2E5D5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final usuario = usuarios[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    usuario['id_usr'].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  usuario['nombre'], // nombre real del usuario
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Usuario: ${usuario['usuario']}'),
                    Text('Contraseña: ${usuario['passwo']}'),
                    Text('Transporte: ${usuario['transporte'] ?? '-'}'),
                    Text('Rol: ${usuario['rol'] ?? '-'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Eliminar usuario"),
                              content: Text("¿Quieres eliminar al usuario '${usuario['nombre']}'?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final url = Uri.parse(
                                      "http://localhost:8000/usuario/${usuario['id_usr']}",
                                    );
                                    final response = await http.delete(url);
                                    Navigator.pop(context);
                                    if (response.statusCode == 200) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Usuario Eliminado")),
                                      );
                                      cargarUsuarios();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Error al eliminar el usuario")),
                                      );
                                    }
                                  },
                                  child: const Text("Eliminar"),
                                ),
                              ],
                            );
                          },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Volver al formulario',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
class EntregasUlista extends StatefulWidget {
  const EntregasUlista({super.key});

  @override
  _EntregasUlistaState createState() => _EntregasUlistaState();
}

class _EntregasUlistaState extends State<EntregasUlista> {
  List<dynamic> entregas = [];

  Future<void> cargarpaquetes() async {
    final url = Uri.parse('http://127.0.0.1:8000/entregas/lista');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        entregas = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar productos: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarpaquetes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 161, 13, 13),
                Color.fromARGB(255, 210, 56, 25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Lista de paquetes',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD97B66),
              Color(0xFFF2E5D5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: entregas.length,
          itemBuilder: (context, index) {
            final entrega = entregas[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      entrega['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.brown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Descripción: ${entrega['descripcion'] ?? '-'}',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Dirección: ${entrega['direc'] ?? '-'}',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Estatus: ${entrega['estatus'] ?? '-'}',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Agente (Id): ${entrega['id_usr'] ?? '-'}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Volver',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}

class EntregasRegistradas extends StatefulWidget {
  const EntregasRegistradas({super.key});

  @override
  _EntregasRegistradasState createState() => _EntregasRegistradasState();
}

class _EntregasRegistradasState extends State<EntregasRegistradas> {
  List<dynamic> entregas = [];

  Future<void> cargarEntregas() async {
    final url = Uri.parse('http://127.0.0.1:8000/entregas/lista'); // Endpoint actualizado
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        entregas = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar entregas: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarEntregas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 161, 13, 13),
                Color.fromARGB(255, 210, 56, 25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Entregas Registradas',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD97B66),
              Color(0xFFF2E5D5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: entregas.length,
          itemBuilder: (context, index) {
            final entrega = entregas[index];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Paquete: ${entrega['nombre_paquete'] ?? 'Desconocido'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.brown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Descripción: ${entrega['descripcion_paquete'] ?? '-'}',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Dirección: ${entrega['direccion_paquete'] ?? '-'}',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Estatus: ${entrega['estatus_paquete'] ?? '-'}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Fecha de entrega: ${entrega['fecha'] ?? '-'}',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Ubicación: Lat ${entrega['latitud'] ?? '-'}, Lng ${entrega['longitud'] ?? '-'}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    entrega['foto'] != null
                        ? Image.network(
                            'http://127.0.0.1:8000/${entrega['foto']}',
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Volver',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}

class UbicacionesLista extends StatefulWidget {
  const UbicacionesLista({super.key});

  @override
  _UbicacionesListaState createState() => _UbicacionesListaState();
}

class _UbicacionesListaState extends State<UbicacionesLista> {
  List<dynamic> ubicaciones = [];

  Future<void> cargarUbicaciones() async {
    final url = Uri.parse('http://127.0.0.1:8000/ubicaciones/lista');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        // Aseguramos que latitud y longitud sean double y la foto tenga la URL completa
        ubicaciones = data.map((u) => {
              "id_ubi": u["id_ubi"],
              "latitud": double.tryParse(u["latitud"].toString()) ?? 0.0,
              "longitud": double.tryParse(u["longitud"].toString()) ?? 0.0,
              "ubi_gps": u["ubi_gps"] ?? "",
              "foto": u["foto"] != null && u["foto"] != "" 
                        ? "http://127.0.0.1:8000/${u['foto']}" 
                        : null
            }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar ubicaciones: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarUbicaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 161, 13, 13),
                Color.fromARGB(255, 210, 56, 25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Ubicaciones Registradas',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD97B66),
              Color(0xFFF2E5D5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: ubicaciones.length,
          itemBuilder: (context, index) {
            final ubicacion = ubicaciones[index];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'ID: ${ubicacion['id_ubi']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Latitud: ${ubicacion['latitud']}',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Longitud: ${ubicacion['longitud']}',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Ubicación GPS: ${ubicacion['ubi_gps']}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ubicacion['foto'] != null
                        ? Image.network(
                            ubicacion['foto'],
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              const Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.grey)),
                          )
                        : const Text(
                            'Sin foto',
                            style: TextStyle(color: Colors.grey),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Volver',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}