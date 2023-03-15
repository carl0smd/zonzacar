import 'package:flutter/material.dart';

class PublicarTrayectoScreen extends StatelessWidget {
  
  final bool isGoingToZonzamas;

  const PublicarTrayectoScreen({Key? key, required this.isGoingToZonzamas}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('Trayecto'),
         elevation: 0,
         backgroundColor: Colors.transparent,
         foregroundColor: Colors.black,
         centerTitle: true,
         actions: [
            IconButton(
               onPressed: () {
                  Navigator.pop(context);
               },
               icon: const Icon(Icons.clear),
            ),
         ],
      ),
      body: Center(
         child: Text('PublicarTrayectoScreen'),
      ),
    );
  }
}