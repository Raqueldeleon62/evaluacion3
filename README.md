# evaluacion3
Archivos de la apliacacion para logistica


Este proyecto permite registrar entregas tomar fotografías asignar paquetes a agentes que estén a este en la base de datos del sistema.
Tiene como funcionalidades:
login de usuarios
listado de entregas 
subir imágenes desde la localhost 
la obtención de la ubicación por GPS 
también registro de nuevos usuarios 
las tecnologías que se utilizaron fueron:
flutter
http
geolocator
gps

COmando para instalar
git clone https://github.com/Raqueldeleon62/evaluacion3
cd evaluacion3
    cd APPI_E3 
    cd eva_u3
//instalar dependencias de flutter
flutter pub get
flutter run
//Api
uvicorn main:app --host 0.0.0.0 --port 8000

Para inciciar sesion debes crear una cuenta, el administardor e puede asignar paquetes, tu entras los ves seleccionas subes foto y ubicacion para completar entrega
