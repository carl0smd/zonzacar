import 'package:flutter/material.dart';

class PublicarTrayectoScreen extends StatelessWidget {
  
  final bool isGoingToZonzamas;

  const PublicarTrayectoScreen({Key? key, required this.isGoingToZonzamas}) : super(key: key);
  
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
      body: Center(
         child: Text('PublicarTrayectoScreen'),
      ),
    );
  }
}