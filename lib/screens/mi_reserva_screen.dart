import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/screens/screens.dart';

import '../widgets/widgets.dart';

// SCREEN TO SHOW THE RESERVATION DETAILS

class MiReservaScreen extends StatefulWidget {
  const MiReservaScreen({Key? key, this.publication}) : super(key: key);

  final dynamic publication;

  @override
  State<MiReservaScreen> createState() => _MiReservaScreenState();
}

class _MiReservaScreenState extends State<MiReservaScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  bool isRatingLoading = false;
  bool alreadyRated = false;

  void checkIfAlreadyRated() async {
    try {
      await DatabaseProvider()
          .checkIfUserHasAlreadyRatedDriver(widget.publication['uid'])
          .then(
        (value) {
          if (value) {
            setState(() {
              alreadyRated = true;
            });
          }
        },
      );
    } catch (e) {
      showSnackbar('Hemos tenido un problema, intenta más tarde', context);
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfAlreadyRated();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseProvider databaseProvider = DatabaseProvider();
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

    //ORIGIN MARKER
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
                    'Reserva',
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
                          builder: (BuildContext context) {
                            return const MenuScreen(
                              initialIndex: 2,
                            );
                          },
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
              const Divider(
                thickness: 1.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 10.0),
              // FUTURE BUILDER TO GET THE USER DATA
              FutureBuilder(
                future: databaseProvider
                    .getUserByUid(widget.publication['conductor']),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    final usuario = snapshot.data[0];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            UserImage(
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
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              withNavBar: false,
                              screen: ChatDetailsScreen(
                                passenger:
                                    FirebaseAuth.instance.currentUser!.uid,
                                driver: widget.publication['conductor'],
                                isDriver: false,
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

              // FUTURE BUILDER TO GET THE VEHICLE DATA
              FutureBuilder(
                future: databaseProvider
                    .getVehicleByUid(widget.publication['vehiculo']),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final vehicle = snapshot.data[0];
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle['marca'] +
                                      ' ' +
                                      vehicle['modelo'] +
                                      ' - ' +
                                      vehicle['combustible'],
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
                                  vehicle['color'] +
                                      ' - ' +
                                      vehicle['matricula'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.directions_car,
                              size: 40,
                              color: Colors.green,
                            ),
                          ],
                        ),
                        //BUTTON TO RATE THE DRIVER
                        widget.publication['estado'] ==
                                DatabaseProvider.publicationState['finalizada']
                            ? const SizedBox(
                                height: 20,
                              )
                            : Container(),
                        widget.publication['estado'] ==
                                DatabaseProvider.publicationState['finalizada']
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: alreadyRated
                                        ? null
                                        : () {
                                            double stars = 0;

                                            //show dialog to rate driver with stars
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Valorar conductor',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        '¿Cómo valorarías a tu conductor?',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                        height: 30,
                                                      ),
                                                      RatingBar.builder(
                                                        initialRating: 0,
                                                        minRating: 1,
                                                        direction:
                                                            Axis.horizontal,
                                                        allowHalfRating: false,
                                                        itemCount: 5,
                                                        itemPadding:
                                                            const EdgeInsets
                                                                .only(
                                                          right: 4.0,
                                                        ),
                                                        itemBuilder:
                                                            (context, _) =>
                                                                const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        onRatingUpdate:
                                                            (rating) {
                                                          setState(() {
                                                            stars = rating;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        'Cancelar',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        if (stars == 0) {
                                                          showSnackbar(
                                                            'Debes valorar al conductor',
                                                            context,
                                                          );
                                                          return;
                                                        }
                                                        setState(() {
                                                          isRatingLoading =
                                                              true;
                                                        });
                                                        await databaseProvider
                                                            .rateDriver(
                                                          stars,
                                                          widget.publication[
                                                              'uid'],
                                                          widget.publication[
                                                              'conductor'],
                                                        );
                                                        if (mounted) {
                                                          setState(() {
                                                            isRatingLoading =
                                                                false;
                                                          });
                                                          showSnackbar(
                                                            'Conductor valorado correctamente',
                                                            context,
                                                          );
                                                          Navigator
                                                              .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const MenuScreen(
                                                                initialIndex: 2,
                                                              ),
                                                            ),
                                                            (route) => false,
                                                          );
                                                        }
                                                      },
                                                      child: const Text(
                                                        'Aceptar',
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 10.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'Valorar conductor',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),

              Column(
                children: [
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
                ],
              ),

              //CARBON FOOTPRINT
              HuellaCarbono(
                huellaCarbono: widget.publication['huellaCarbono'],
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
                height: 10,
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
