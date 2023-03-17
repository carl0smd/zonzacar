import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zonzacar/providers/database_provider.dart';

class PublicarTrayectoScreen extends StatefulWidget {

  final String zona;
  final bool isGoingToZonzamas;

  const PublicarTrayectoScreen({Key? key, required this.isGoingToZonzamas, required this.zona}) : super(key: key);

  @override
  State<PublicarTrayectoScreen> createState() => _PublicarTrayectoScreenState();
}

class _PublicarTrayectoScreenState extends State<PublicarTrayectoScreen> {
  
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
    
    return Scaffold(
      appBar: AppBar(
         elevation: 0,
         backgroundColor: Colors.transparent,
         foregroundColor: Colors.black,
         automaticallyImplyLeading: false,
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
      body: _userHasCar ? Center(
         child: Text('Tienes coche'),
      )
      : Container(
        child: Center(
           child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 const Text('Añade un coche a tu perfil para poder publicar trayectos'),
                 IconButton(onPressed: (){}, icon: Icon(Icons.directions_car))
              ],
           ),
        ),
      ),
    );
  }
}