import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/providers/google_services_provider.dart';
import 'package:zonzacar/screens/screens.dart';
import 'package:zonzacar/widgets/dialogos_para_editar.dart';

class PublicarTrayectoScreen extends StatefulWidget {

  final String zona;
  final double zonaLat;
  final double zonaLng;
  final bool isGoingToZonzamas;

  const PublicarTrayectoScreen({Key? key, required this.isGoingToZonzamas, required this.zona, required this.zonaLat, required this.zonaLng}) : super(key: key);

  @override
  State<PublicarTrayectoScreen> createState() => _PublicarTrayectoScreenState();
}

class _PublicarTrayectoScreenState extends State<PublicarTrayectoScreen> {

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  
  DatabaseProvider databaseProvider = DatabaseProvider();
  bool _userHasCar = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasCar();
  }

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

    String origin = widget.isGoingToZonzamas ? "${widget.zonaLat.toString()},${widget.zonaLng.toString()}" : "28.967505747317997,-13.560605681682436";
    String destination = widget.isGoingToZonzamas ? "28.967505747317997,-13.560605681682436" : "${widget.zonaLat.toString()},${widget.zonaLng.toString()}";

    GoogleServicesProvider googleServicesProvider = GoogleServicesProvider();

    List<PointLatLng> result = [];

    Marker originMarker = Marker(
      markerId: const MarkerId('origin'),
      position: LatLng(double.parse(origin.split(',')[0]), double.parse(origin.split(',')[1])),
      infoWindow: const InfoWindow(title: 'Origen'),
      draggable: true,
      consumeTapEvents: true,
      onTap: () {
        _controller.future.then((value) {
          value.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(double.parse(origin.split(',')[0]), double.parse(origin.split(',')[1])),
            zoom: 14,
          )));
        });
      },
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onDragEnd: (newPosition) async {
        await googleServicesProvider.getPolylineAndDistance('${newPosition.latitude},${newPosition.longitude}', destination).then((value) {
          setState(() {
            origin = '${newPosition.latitude},${newPosition.longitude}';
            result.clear();
            result.addAll(PolylinePoints().decodePolyline(value[0]));
          });
        });
      },
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(double.parse(destination.split(',')[0]), double.parse(destination.split(',')[1])),
      infoWindow: const InfoWindow(title: 'Destino'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(double.parse(origin.split(',')[0]), double.parse(origin.split(',')[1])),
      zoom: 14,
    );
   
      return FutureBuilder(
        future: googleServicesProvider.getPolylineAndDistance(origin, destination),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            result.clear();
            result.addAll(PolylinePoints().decodePolyline(snapshot.data[0]));
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                centerTitle: true,
                leading: _userHasCar ? Container(
                  margin: const EdgeInsets.only(left: 5.0),
                  child: IconButton(
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context, 
                        withNavBar: false,
                        screen: FormularioTrayectoScreen(distancia: snapshot.data[1],),
                      );
                    },
                    icon: const Icon(Icons.check, size: 40, color: Colors.green),
                  ),
                )
                : Container(),
                title: _userHasCar ? const Text('¿Esta es la ruta?') : null,
                actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 5.0),
                      child: IconButton(
                        onPressed: () {
                            Navigator.of(context).pop();               
                        },
                        icon: const Icon(Icons.clear, size: 40, color: Colors.green),
                      ),
                    ),
                ],
              ),
              body: _userHasCar ? GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: kGooglePlex,
                myLocationEnabled: true,
                compassEnabled: true,
                scrollGesturesEnabled: true,
                markers: {
                  originMarker,
                  destinationMarker,
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('poly'),
                    color: Colors.green,
                    points: result.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                    width: 5,
                  ),
                },
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              )
              : Container(
                child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Para publicar trayectos debes añadir un vehículo a tu perfil', 
                        style: TextStyle(fontSize: 20.0, color: Colors.green), 
                        overflow: TextOverflow.clip, 
                        textAlign: TextAlign.center,),
                      ],
                  ),
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