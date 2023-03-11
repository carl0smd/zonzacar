import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
   
  const PerfilScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car, color: Colors.black,)),
              Tab(icon: Icon(Icons.directions_transit, color: Colors.black)),]
          ),
        ),
        body: Center(
           child: Text('PerfilScreen'),
        ),
      ),
    );
  }
}