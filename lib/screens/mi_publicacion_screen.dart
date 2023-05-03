import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/screens/screens.dart';
import 'package:zonzacar/widgets/widgets.dart';

class MiPublicacionScreen extends StatefulWidget {
  const MiPublicacionScreen({Key? key, this.publicacion}) : super(key: key);

  final dynamic publicacion;

  @override
  State<MiPublicacionScreen> createState() => _MiPublicacionScreenState();
}

class _MiPublicacionScreenState extends State<MiPublicacionScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    DatabaseProvider databaseProvider = DatabaseProvider();
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(
        double.parse(
          widget.publicacion['coordenadasOrigen'].split(',')[0],
        ),
        double.parse(
          widget.publicacion['coordenadasOrigen'].split(',')[1],
        ),
      ),
      zoom: 16,
    );

    //Marker origen
    Marker origenMarker = Marker(
      markerId: const MarkerId('marker'),
      position: LatLng(
        double.parse(
          widget.publicacion['coordenadasOrigen'].split(',')[0],
        ),
        double.parse(
          widget.publicacion['coordenadasOrigen'].split(',')[1],
        ),
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
      consumeTapEvents: true,
      onTap: null,
    );

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Publicación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
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
              //divider
              const Divider(
                thickness: 1.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 10.0),
              FutureBuilder(
                future:
                    databaseProvider.getPassengers(widget.publicacion['uid']),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData && snapshot.data.isNotEmpty) {
                    final pasajeros = snapshot.data;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Pasajeros',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            const Icon(
                              Icons.people,
                              color: Colors.green,
                              size: 30,
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              '${pasajeros.length}/${widget.publicacion['asientosDisponibles']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 70,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Stack(
                                    children: [
                                      for (var pasajero in pasajeros)
                                        //imagen de usuario en forma de stack para que se vean todas las imagenes un poco superpuestas
                                        Positioned(
                                          left: pasajeros.indexOf(pasajero) *
                                              30.0,
                                          child: ImagenUsuario(
                                            userImage: pasajero['imagenPerfil'],
                                            radiusOutterCircle: 32,
                                            radiusImageCircle: 30,
                                            iconSize: 30,
                                          ),
                                        ),
                                    ],
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
                        ),
                      ],
                    );
                  } else if (snapshot.hasData && snapshot.data.isEmpty) {
                    return Row(
                      children: const [
                        Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 30,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'No hay pasajeros',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
              const SizedBox(),
              const SizedBox(),

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
                    _controller.complete(controller);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
