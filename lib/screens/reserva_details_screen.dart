import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/widgets/widgets.dart';

class ReservaDetailsScreen extends StatefulWidget {
  final String id;
  final String userImage;
  final String userName;
  final bool isGoingToZonzamas;

  const ReservaDetailsScreen({
    Key? key,
    required this.id,
    required this.userName,
    required this.userImage,
    required this.isGoingToZonzamas,
  }) : super(key: key);

  @override
  State<ReservaDetailsScreen> createState() => _ReservaDetailsScreenState();
}

class _ReservaDetailsScreenState extends State<ReservaDetailsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool _purchaseInProgress = false;

  @override
  Widget build(BuildContext context) {
    DatabaseProvider databaseProvider = DatabaseProvider();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del trayecto',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(size: 40, color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: FutureBuilder(
            future: databaseProvider.getPublications(widget.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final publication = snapshot.data[0];
                CameraPosition kGooglePlex = CameraPosition(
                  target: LatLng(
                    double.parse(
                      publication['coordenadasOrigen'].split(',')[0],
                    ),
                    double.parse(
                      publication['coordenadasOrigen'].split(',')[1],
                    ),
                  ),
                  zoom: 16,
                );
                Marker marker = Marker(
                  markerId: const MarkerId('marker'),
                  position: LatLng(
                    double.parse(
                      publication['coordenadasOrigen'].split(',')[0],
                    ),
                    double.parse(
                      publication['coordenadasOrigen'].split(',')[1],
                    ),
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  consumeTapEvents: true,
                  onTap: null,
                );

                return Column(
                  children: [
                    InfoTrayecto(publication: publication),
                    InfoPrecio(publication: publication),
                    infoConductor(
                      databaseProvider,
                      publication,
                      widget.userImage,
                      context,
                    ),
                    InfoMapa(
                      widget: widget,
                      kGooglePlex: kGooglePlex,
                      marker: marker,
                      controller: _controller,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    buyButton(context, databaseProvider),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  Container buyButton(BuildContext context, DatabaseProvider databaseProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: ElevatedButtonTheme(
        data: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            elevation: 1,
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) => buildSheet(databaseProvider),
            );
          },
          child: const Text(
            'Continuar',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Container infoConductor(
    DatabaseProvider databaseProvider,
    publication,
    userImage,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 250,
                child: Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ImagenUsuario(
                userImage: userImage,
                radiusOutterCircle: 42,
                radiusImageCircle: 40,
                iconSize: 40,
              ),
            ],
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
            future: databaseProvider.getVehicleByUid(publication['vehiculo']),
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
                          vehicle['marca'] + ' ' + vehicle['modelo'],
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
                          vehicle['color'],
                          style: const TextStyle(fontSize: 20),
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
        ],
      ),
    );
  }

  buildSheet(DatabaseProvider databaseProvider) {
    return Container(
      //pay with card, cash or cancel
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Método de pago',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _purchaseInProgress
                      ? null
                      : () {
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
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return ListTile(
                    leading: const Icon(
                      Icons.money,
                      color: Colors.green,
                      size: 30,
                    ),
                    title: const Text(
                      'Efectivo',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green,
                    ),
                    onTap: _purchaseInProgress
                        ? null
                        : () async {
                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text(
                                  'Confirmar reserva',
                                  style: TextStyle(fontSize: 20),
                                ),
                                content: const Text(
                                  '¿Estás seguro de reservar este trayecto?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: _purchaseInProgress
                                        ? null
                                        : () {
                                            setState(() {
                                              _purchaseInProgress = false;
                                            });
                                            Navigator.pop(context);
                                          },
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _purchaseInProgress
                                        ? null
                                        : () {
                                            setState(() {
                                              _purchaseInProgress = true;
                                            });
                                            Navigator.pop(context);
                                          },
                                    child: const Text(
                                      'Confirmar',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (_purchaseInProgress && mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (_purchaseInProgress) {
                              if (await databaseProvider
                                  .checkIfFull(widget.id)) {
                                setState(() {
                                  _purchaseInProgress = false;
                                });
                                if (mounted) {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Trayecto completo'),
                                      content: const Text(
                                        'Lo sentimos, alguien se ha adelantado a tu reserva y el coche está lleno.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              'home',
                                              (route) => false,
                                            );
                                          },
                                          child: const Text('Ok'),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                              } else {
                                try {
                                  await databaseProvider
                                      .saveReservation(
                                    widget.id,
                                    FirebaseAuth.instance.currentUser!.uid,
                                  )
                                      .then(
                                    (value) {
                                      if (mounted) {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          'home',
                                          (route) => false,
                                        );
                                        setState(() {
                                          _purchaseInProgress = false;
                                        });
                                        showSnackbar(
                                          'Reserva realizada con éxito',
                                          context,
                                        );
                                      }
                                    },
                                  );
                                } catch (e) {
                                  setState(() {
                                    _purchaseInProgress = false;
                                  });
                                  if (mounted) {
                                    showSnackbar(
                                      'Error al reservar trayecto, inténtelo más tarde',
                                      context,
                                    );
                                  }
                                }
                              }
                            }
                          },
                  );
                } else {
                  return ListTile(
                    leading: const Icon(
                      Icons.credit_card,
                      color: Colors.grey,
                      size: 30,
                    ),
                    title: const Text(
                      'Tarjeta de crédito/débito (Próximamente)',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    ),
                    onTap: _purchaseInProgress ? null : () {},
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InfoMapa extends StatelessWidget {
  const InfoMapa({
    super.key,
    required this.widget,
    required this.kGooglePlex,
    required this.marker,
    required Completer<GoogleMapController> controller,
  }) : _controller = controller;

  final ReservaDetailsScreen widget;
  final CameraPosition kGooglePlex;
  final Marker marker;
  final Completer<GoogleMapController> _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      //show googlemaps with marker in publication['coordenadasOrigen']
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Punto de recogida',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
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
              compassEnabled: true,
              scrollGesturesEnabled: true,
              markers: {marker},
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InfoPrecio extends StatelessWidget {
  const InfoPrecio({
    super.key,
    required this.publication,
  });

  final publication;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Precio para un pasajero',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            '${publication['precio'].toStringAsFixed(2)} €',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoTrayecto extends StatelessWidget {
  const InfoTrayecto({
    super.key,
    required this.publication,
  });

  final publication;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(publication['fecha']),
                ),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                publication['horaSalida'] + 'h',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            publication['origen'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                width: 3.0,
                height: 50.0,
                color: Colors.green,
              ),
              const SizedBox(
                width: 10,
              ),
              const Icon(
                Icons.directions_car,
                color: Colors.green,
                size: 30,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                publication['distancia'],
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                width: 10,
              ),
              const Icon(
                Icons.access_time,
                color: Colors.green,
                size: 30,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                publication['duracionViaje'],
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            publication['destino'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
