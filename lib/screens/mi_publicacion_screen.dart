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
  const MiPublicacionScreen({Key? key, this.publication}) : super(key: key);

  final dynamic publication;

  @override
  State<MiPublicacionScreen> createState() => _MiPublicacionScreenState();
}

class _MiPublicacionScreenState extends State<MiPublicacionScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  bool isTripStarted = false;
  bool isTripFinished = false;

  void checkState() {
    if (widget.publication['estado'] == 'En curso' ||
        widget.publication['estado'] == 'Finalizada') {
      setState(() {
        isTripStarted = true;
      });
    }
    if (widget.publication['estado'] == 'finalizado') {
      setState(() {
        isTripFinished = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkState();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseProvider databaseProvider = DatabaseProvider();
    String tripState = widget.publication['estado'];

    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(
        double.parse(
          widget.publication['coordenadasOrigen'].split(',')[0],
        ),
        double.parse(
          widget.publication['coordenadasOrigen'].split(',')[1],
        ),
      ),
      zoom: 16,
    );

    //Marker origen
    Marker originMarker = Marker(
      markerId: const MarkerId('marker'),
      position: LatLng(
        double.parse(
          widget.publication['coordenadasOrigen'].split(',')[0],
        ),
        double.parse(
          widget.publication['coordenadasOrigen'].split(',')[1],
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const MenuScreen(
                            initialIndex: 2,
                          ),
                        ),
                        (route) => false,
                      );
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
                future: databaseProvider
                    .getPassengersFromPublication(widget.publication['uid']),
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
                              '${pasajeros.length}/${widget.publication['asientosDisponibles']}',
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
                                          child: UserImage(
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
                                //return a list of users and when you click on one of them, it opens the chat screen

                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 20.0,
                                    ),
                                    child: FutureBuilder(
                                      future: databaseProvider
                                          .getPassengersFromPublication(
                                        widget.publication['uid'],
                                      ),
                                      builder: (
                                        BuildContext context,
                                        AsyncSnapshot<dynamic> snapshot,
                                      ) {
                                        if (snapshot.hasData &&
                                            snapshot.data.isNotEmpty) {
                                          final pasajeros = snapshot.data;
                                          return ListView.separated(
                                            separatorBuilder: (
                                              BuildContext context,
                                              int index,
                                            ) =>
                                                const Divider(
                                              thickness: 0.5,
                                              color: Colors.grey,
                                            ),
                                            itemCount: pasajeros.length,
                                            itemBuilder: (
                                              BuildContext context,
                                              int index,
                                            ) {
                                              return ListTile(
                                                leading: UserImage(
                                                  userImage: pasajeros[index]
                                                      ['imagenPerfil'],
                                                  radiusOutterCircle: 28,
                                                  radiusImageCircle: 26,
                                                  iconSize: 26,
                                                ),
                                                title: Text(
                                                  pasajeros[index]
                                                      ['nombreCompleto'],
                                                ),
                                                trailing: IconButton(
                                                  icon: const Icon(
                                                    Icons.send_rounded,
                                                    color: Colors.green,
                                                    size: 30,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    PersistentNavBarNavigator
                                                        .pushNewScreen(
                                                      context,
                                                      screen: ChatDetailsScreen(
                                                        driver:
                                                            widget.publication[
                                                                'conductor'],
                                                        passenger:
                                                            pasajeros[index]
                                                                ['uid'],
                                                        isDriver: true,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        } else if (snapshot.hasData &&
                                            snapshot.data.isEmpty) {
                                          return const Center(
                                            child: Text('No hay pasajeros'),
                                          );
                                        } else {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    ),
                                  ),
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
              //botones circulares para iniciar el viaje en naranja, boton para finalizar el viaje en gris
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //boton para iniciar el viaje
                  ElevatedButton(
                    onPressed: isTripStarted
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Iniciar viaje'),
                                content: const Text(
                                  '¿Estás seguro de que quieres iniciar el viaje?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      final bool isPublicationToday =
                                          await databaseProvider
                                              .checkIfPublicationStartsTripToday(
                                        widget.publication['uid'],
                                      );

                                      if (isPublicationToday) {
                                        if (widget.publication['pasajeros']
                                                .length >
                                            0) {
                                          setState(() {
                                            tripState = DatabaseProvider
                                                .publicationState['encurso']!;
                                            isTripStarted = true;
                                          });
                                          await databaseProvider
                                              .updatePublicationState(
                                            widget.publication['uid'],
                                            tripState,
                                          );
                                          if (mounted) Navigator.pop(context);
                                        } else {
                                          if (mounted) {
                                            Navigator.pop(context);
                                            showSnackbar(
                                              'No puedes iniciar un viaje sin pasajeros',
                                              context,
                                            );
                                          }
                                        }
                                      } else {
                                        if (mounted) {
                                          Navigator.pop(context);
                                          showSnackbar(
                                            'No puedes iniciar un viaje que no sea hoy',
                                            context,
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Sí'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('No'),
                                  ),
                                ],
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    child: const Text(
                      'Iniciar viaje',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  //boton para finalizar el viaje
                  ElevatedButton(
                    onPressed: !isTripFinished && isTripStarted
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Finalizar viaje'),
                                content: const Text(
                                  '¿Estás seguro de que quieres finalizar el viaje?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        tripState = DatabaseProvider
                                            .publicationState['finalizada']!;
                                        isTripFinished = true;
                                      });
                                      await databaseProvider
                                          .updatePublicationState(
                                        widget.publication['uid'],
                                        tripState,
                                      );
                                      if (mounted) Navigator.pop(context);
                                    },
                                    child: const Text('Sí'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('No'),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    child: const Text(
                      'Finalizar viaje',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
                  markers: {originMarker},
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
