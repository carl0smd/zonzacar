import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/screens/screens.dart';
import 'package:zonzacar/widgets/widgets.dart';

class MisTrayectosScreen extends StatelessWidget {
  const MisTrayectosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseProvider databaseProvider = DatabaseProvider();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  tabs: [
                    Tab(text: 'Mis reservas'),
                    Tab(text: 'Mis publicaciones'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      MisReservasYPublicaciones(
                        futureReservas:
                            databaseProvider.getPublicationsByPassenger(),
                      ),
                      MisReservasYPublicaciones(
                        futurePublicaciones:
                            databaseProvider.getPublicationsByDriver(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MisReservasYPublicaciones extends StatelessWidget {
  const MisReservasYPublicaciones({
    super.key,
    this.futureReservas,
    this.futurePublicaciones,
  });

  final Future<dynamic>? futureReservas;
  final Future<dynamic>? futurePublicaciones;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureReservas ?? futurePublicaciones,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.length > 0) {
          List myList = snapshot.data;
          return Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return futureReservas != null
                    ? CardInfoPublicacion(
                        origen: myList[index]['origen'],
                        destino: myList[index]['destino'],
                        fecha: myList[index]['fecha'],
                        hora: myList[index]['horaSalida'],
                        conductor: myList[index]['conductor'],
                        publicacion: myList[index],
                      )
                    : Card(
                        child: ListTile(
                          title: Text(myList[index]['origen']),
                          subtitle: Text(myList[index]['destino']),
                        ),
                      );
              },
            ),
          );
        } else if (snapshot.hasData && snapshot.data.length == 0) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                futureReservas != null
                    ? const Text(
                        'No tienes reservas',
                        style: TextStyle(fontSize: 25.0, color: Colors.grey),
                      )
                    : const Text(
                        'No tienes publicaciones',
                        style: TextStyle(fontSize: 25.0, color: Colors.grey),
                      ),
                const SizedBox(width: 10.0),
                const Icon(
                  Icons.sentiment_dissatisfied_outlined,
                  color: Colors.grey,
                  size: 30.0,
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class CardInfoPublicacion extends StatefulWidget {
  const CardInfoPublicacion({
    super.key,
    required this.origen,
    required this.destino,
    required this.fecha,
    required this.hora,
    required this.conductor,
    required this.publicacion,
  });

  final String origen;
  final String destino;
  final fecha;
  final String hora;
  final String conductor;
  final publicacion;

  @override
  State<CardInfoPublicacion> createState() => _CardInfoPublicacionState();
}

class _CardInfoPublicacionState extends State<CardInfoPublicacion> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.origen,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10.0),
            //Fecha, hora de salida y pasajeros permitidos
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Linea vertical
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  width: 3.0,
                  height: 50.0,
                  color: Colors.green,
                ),
                //fecha
                const Icon(
                  Icons.calendar_today,
                  color: Colors.green,
                ),
                const SizedBox(width: 10.0),
                Text(
                  DateFormat('dd/MM/yyyy').format(
                    DateTime.fromMillisecondsSinceEpoch(
                      widget.fecha,
                    ),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                //hora de salida
                const Icon(
                  Icons.access_time,
                  color: Colors.green,
                ),
                const SizedBox(width: 10.0),
                Text(
                  widget.hora,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
            //Destino
            const SizedBox(height: 10.0),
            Text(
              widget.destino,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            //Row button ver y cancelar
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) =>
                          buildSheet(widget.publicacion, context, _controller),
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 1,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text('Ver'),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 1,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildSheet(publicacion, context, mapController) {
  DatabaseProvider databaseProvider = DatabaseProvider();
  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(
      double.parse(
        publicacion['coordenadasOrigen'].split(',')[0],
      ),
      double.parse(
        publicacion['coordenadasOrigen'].split(',')[1],
      ),
    ),
    zoom: 16,
  );

  //Marker origen
  Marker origenMarker = Marker(
    markerId: const MarkerId('marker'),
    position: LatLng(
      double.parse(
        publicacion['coordenadasOrigen'].split(',')[0],
      ),
      double.parse(
        publicacion['coordenadasOrigen'].split(',')[1],
      ),
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    ),
    consumeTapEvents: true,
    onTap: null,
  );

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reserva',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.red,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        FutureBuilder(
          future: databaseProvider.getUserByUid(publicacion['conductor']),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              final usuario = snapshot.data[0];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ImagenUsuario(
                        userImage: usuario['imagenPerfil'],
                        radiusOutterCircle: 32,
                        radiusImageCircle: 30,
                        iconSize: 30,
                      ),
                      const SizedBox(width: 10.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          usuario['nombreCompleto'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  //icon button for chat
                  IconButton(
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        withNavBar: false,
                        screen: const ChatScreen(),
                      );
                    },
                    icon: const Icon(
                      Icons.chat,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 1,
          width: double.infinity,
          child: Container(
            color: Colors.black26,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        FutureBuilder(
          future: databaseProvider.getVehicleByUid(publicacion['vehiculo']),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final vehicle = snapshot.data[0];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle['marca'].toUpperCase() +
                            ' ' +
                            vehicle['modelo'].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        vehicle['color'] + ' - ' + vehicle['matricula'],
                        style:
                            const TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.directions_car,
                    size: 40,
                    color: Colors.green,
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 1,
          width: double.infinity,
          child: Container(
            color: Colors.black26,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: const [
            Text(
              'Punto de recogida',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Flexible(
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: kGooglePlex,
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            myLocationEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            markers: {origenMarker},
            onMapCreated: (GoogleMapController controller) {
              if (!mapController.isCompleted) {
                mapController.complete(controller);
              } else {
                mapController = null;
              }
            },
          ),
        ),
      ],
    ),
  );
}
