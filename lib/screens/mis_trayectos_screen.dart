import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/screens/screens.dart';
import 'package:zonzacar/widgets/widgets.dart';

class MisTrayectosScreen extends StatefulWidget {
  const MisTrayectosScreen({Key? key}) : super(key: key);

  @override
  State<MisTrayectosScreen> createState() => _MisTrayectosScreenState();
}

class _MisTrayectosScreenState extends State<MisTrayectosScreen> {
  bool _isPermissionGranted = false;

  void _askForLocationPermission() async {
    final status = await Permission.location.request();

    switch (status) {
      case PermissionStatus.granted:
        setState(() {
          _isPermissionGranted = true;
        });
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
      default:
        setState(() {
          _isPermissionGranted = false;
        });
        openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    _askForLocationPermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseProvider databaseProvider = DatabaseProvider();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                      _isPermissionGranted
                          ? MisReservasYPublicaciones(
                              futureReservas:
                                  databaseProvider.getPublicationsByPassenger(),
                            )
                          : solicitarGps(true),
                      _isPermissionGranted
                          ? MisReservasYPublicaciones(
                              futurePublicaciones:
                                  databaseProvider.getPublicationsByDriver(),
                            )
                          : solicitarGps(false),
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

  Center solicitarGps(bool reservas) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_disabled,
            size: 100.0,
            color: Colors.grey,
          ),
          reservas
              ? const Text(
                  'Necesitas conceder permisos de ubicación para ver tu localización y punto de recogida',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                )
              : const Text(
                  'Necesitas conceder permisos de ubicación para ver tu localización y punto de recogida',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            onPressed: _askForLocationPermission,
            child: const Text('Conceder permisos'),
          ),
        ],
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
                    ? CardInfo(
                        publicacion: myList[index],
                        isPassenger: true,
                      )
                    : CardInfo(
                        publicacion: myList[index],
                        isPassenger: false,
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

class CardInfo extends StatefulWidget {
  const CardInfo({
    super.key,
    required this.publicacion,
    required this.isPassenger,
  });

  final publicacion;
  final bool isPassenger;

  @override
  State<CardInfo> createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Map colores = {
    'lleno': Colors.red[300],
    'disponible': Colors.green[300],
    'encurso': Colors.yellow[300],
    'finalizada': Colors.grey[300],
  };

  getColores(estado) {
    switch (estado) {
      case 'Disponible':
        return Colors.green;
      case 'Llena':
        return Colors.red[400];
      case 'En curso':
        return Colors.blue[400];
      case 'Finalizada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseProvider databaseProvider = DatabaseProvider();
    bool isLoading = false;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Estado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: databaseProvider
                      .getPublications(widget.publicacion['uid'])
                      .asStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data.length > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          color: getColores(snapshot.data[0]['estado']),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          snapshot.data[0]['estado'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Cargando...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 20.0, thickness: 2.0),
            Text(
              widget.publicacion['origen'],
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
                const SizedBox(width: 8.0),
                Text(
                  DateFormat('dd/MM/yyyy').format(
                    DateTime.fromMillisecondsSinceEpoch(
                      widget.publicacion['fecha'],
                    ),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                //hora de salida
                const Icon(
                  Icons.access_time,
                  color: Colors.green,
                ),
                const SizedBox(width: 8.0),
                Text(
                  widget.publicacion['horaSalida'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                //pasajeros permitidos
                const Icon(
                  Icons.people,
                  color: Colors.green,
                ),
                const SizedBox(width: 8.0),
                Text(
                  widget.publicacion['pasajeros'].length.toString() +
                      '/' +
                      widget.publicacion['asientosDisponibles'].toString(),
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
              widget.publicacion['destino'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            //Row button ver y cancelar
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.publicacion['precio'].toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    const Icon(
                      Icons.euro,
                      color: Colors.green,
                      size: 20,
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.isPassenger
                            ? PersistentNavBarNavigator.pushNewScreen(
                                context,
                                withNavBar: false,
                                screen: MiReservaScreen(
                                  publicacion: widget.publicacion,
                                ),
                              )
                            : PersistentNavBarNavigator.pushNewScreen(
                                context,
                                withNavBar: false,
                                screen: MiPublicacionScreen(
                                  publicacion: widget.publicacion,
                                ),
                              );
                      },
                      style: ElevatedButton.styleFrom(
                        //height 20
                        minimumSize: const Size(80.0, 35.0),
                        elevation: 1,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text('Ver'),
                    ),
                    widget.publicacion['estado'] ==
                                DatabaseProvider
                                    .estadoPublicacion['disponible'] ||
                            widget.publicacion['estado'] ==
                                DatabaseProvider.estadoPublicacion['llena']
                        ? Row(
                            children: [
                              const SizedBox(width: 10.0),
                              ElevatedButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Cancelar publicación'),
                                        content: const Text(
                                          '¿Está seguro de cancelar su reserva?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'No',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    try {
                                                      if (widget.isPassenger) {
                                                        await databaseProvider
                                                            .deleteReservation(
                                                          widget.publicacion[
                                                              'uid'],
                                                        );
                                                      } else {
                                                        await databaseProvider
                                                            .deletePublication(
                                                          widget.publicacion[
                                                              'uid'],
                                                        );
                                                      }
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      if (mounted) {
                                                        Navigator
                                                            .pushNamedAndRemoveUntil(
                                                          context,
                                                          'home',
                                                          (route) => false,
                                                        );
                                                        if (widget
                                                            .isPassenger) {
                                                          showSnackbar(
                                                            'Reserva cancelada con éxito',
                                                            context,
                                                          );
                                                        } else {
                                                          showSnackbar(
                                                            'Publicación cancelada con éxito',
                                                            context,
                                                          );
                                                        }
                                                      }
                                                    } catch (e) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      Navigator.pop(context);
                                                      if (widget.isPassenger) {
                                                        showSnackbar(
                                                          'Error al cancelar la reserva, inténtelo más tarde',
                                                          context,
                                                        );
                                                      } else {
                                                        showSnackbar(
                                                          'Error al cancelar la publicación, inténtelo más tarde',
                                                          context,
                                                        );
                                                      }
                                                    }
                                                  },
                                            child: const Text('Si'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(80.0, 35.0),
                                  elevation: 1,
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
