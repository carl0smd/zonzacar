import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/providers/google_services_provider.dart';
import 'package:zonzacar/screens/screens.dart';

// SCREEN TO SHOW THE MAP TO PUBLISH A TRIP
class PublicarTrayectoScreen extends StatefulWidget {
  final String zone;
  final double zoneLat;
  final double zoneLng;
  final bool isGoingToZonzamas;

  const PublicarTrayectoScreen({
    Key? key,
    required this.isGoingToZonzamas,
    required this.zone,
    required this.zoneLat,
    required this.zoneLng,
  }) : super(key: key);

  @override
  State<PublicarTrayectoScreen> createState() => _PublicarTrayectoScreenState();
}

class _PublicarTrayectoScreenState extends State<PublicarTrayectoScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  DatabaseProvider databaseProvider = DatabaseProvider();
  bool _userHasCar = false;
  String _mapTheme = '';

  @override
  void initState() {
    super.initState();
    _checkIfUserHasCar();
    //VARIABLE THAT CONTAINS THE MAP THEME
    DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/classic_no_labels.json')
        .then((string) {
      _mapTheme = string;
    });
  }

  //FUNCTION TO CHECK IF THE USER HAS A CAR
  void _checkIfUserHasCar() async {
    await databaseProvider.getVehicles().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          _userHasCar = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String origin = widget.isGoingToZonzamas
        ? "${widget.zoneLat.toString()},${widget.zoneLng.toString()}"
        : "28.967505747317997,-13.560605681682436";
    String destination = widget.isGoingToZonzamas
        ? "28.967505747317997,-13.560605681682436"
        : "${widget.zoneLat.toString()},${widget.zoneLng.toString()}";

    GoogleServicesProvider googleServicesProvider = GoogleServicesProvider();

    List<PointLatLng> result = [];

    //ORIGIN MARKER
    Marker originMarker = Marker(
      markerId: const MarkerId('origin'),
      position: LatLng(
        double.parse(origin.split(',')[0]),
        double.parse(origin.split(',')[1]),
      ),
      infoWindow: const InfoWindow(title: 'Origen'),
      consumeTapEvents: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onTap: () {
        _controller.future.then((value) {
          value.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              double.parse(origin.split(',')[0]),
              double.parse(origin.split(',')[1]),
            ),
            zoom: 18,
          )));
        });
      },
    );

    //DESTINATION MARKER
    Marker destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(
        double.parse(destination.split(',')[0]),
        double.parse(destination.split(',')[1]),
      ),
      infoWindow: const InfoWindow(title: 'Destino'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      consumeTapEvents: true,
      onTap: () {
        _controller.future.then((value) {
          value.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              double.parse(destination.split(',')[0]),
              double.parse(destination.split(',')[1]),
            ),
            zoom: 18,
          )));
        });
      },
    );

    //CAMERA POSITION
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(
        double.parse(origin.split(',')[0]),
        double.parse(origin.split(',')[1]),
      ),
      zoom: 16,
    );

    //FUTURE BUILDER TO GET THE POLYLINE
    return FutureBuilder(
      future: googleServicesProvider.getPolylineAndDistanceAndDuration(
        origin,
        destination,
      ),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data[0] != '') {
          result.clear();
          result.addAll(PolylinePoints().decodePolyline(snapshot.data[0]));
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
              centerTitle: true,
              leading: _userHasCar
                  ? Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      // Botón para ir al formulario
                      child: IconButton(
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            withNavBar: false,
                            screen: FormularioTrayectoScreen(
                              distance: snapshot.data[1],
                              duration: snapshot.data[2],
                              origin: widget.isGoingToZonzamas
                                  ? widget.zone
                                  : 'CIFP Zonzamas',
                              destination: widget.isGoingToZonzamas
                                  ? 'CIFP Zonzamas'
                                  : widget.zone,
                              coordsOrigin: origin,
                              coordsDestination: destination,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.check,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(),
              title: _userHasCar
                  ? const Text(
                      '¿Crear ruta?',
                      style: TextStyle(color: Colors.white),
                    )
                  : null,
              actions: [
                // BUTTON TO CLOSE THE SCREEN
                Container(
                  margin: const EdgeInsets.only(right: 5.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon:
                        const Icon(Icons.clear, size: 40, color: Colors.white),
                  ),
                ),
              ],
            ),
            // IF USER HAS CAR SHOW THE MAP
            body: _userHasCar
                ? Column(
                    children: [
                      Flexible(
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: kGooglePlex,
                          compassEnabled: true,
                          scrollGesturesEnabled: true,
                          markers: {
                            originMarker,
                            destinationMarker,
                          },
                          polylines: {
                            Polyline(
                              polylineId: const PolylineId('poly'),
                              color: Theme.of(context).primaryColor,
                              points: result
                                  .map((e) => LatLng(e.latitude, e.longitude))
                                  .toList(),
                              width: 5,
                            ),
                          },
                          onMapCreated: (GoogleMapController controller) {
                            controller.setMapStyle(_mapTheme);
                            _controller.complete(controller);
                          },
                        ),
                      ),
                      Container(
                        color: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: const [
                            Text(
                              '* Esta ruta es solo orientativa, el conductor podrá tomar otro camino siempre que llegue a su destino',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Para publicar trayectos debes añadir un vehículo a tu perfil',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Theme.of(context).primaryColor,
                            ),
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
          );
          // IF ORIGIN OR DESTINATION IS IN LA GRACIOSA
        } else if (snapshot.hasData && snapshot.data[0] == '') {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 40,
              ),
            ),
            body: Center(
              child: Text(
                'Lo sentimos actualmente no permitimos trayectos entre Lanzarote y La Graciosa',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Theme.of(context).primaryColor,
                ),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
