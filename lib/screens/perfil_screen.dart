import 'package:flutter/material.dart';
import 'package:zonzacar/providers/auth_provider.dart';
import 'package:zonzacar/screens/login_screen.dart';

class PerfilScreen extends StatelessWidget {
   
  const PerfilScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    AuthProvider authProvider = AuthProvider();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authProvider.logOut();
                Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ],
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