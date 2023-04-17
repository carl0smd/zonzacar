import 'package:flutter/material.dart';

class ReservaDetailsScreen extends StatelessWidget {

  final String id;
   
  const ReservaDetailsScreen({Key? key, required this.id}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
         child: Text('ReservaDetaislScreen $id'),
      ),
    );
  }
}