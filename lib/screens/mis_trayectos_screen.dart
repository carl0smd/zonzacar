import 'package:flutter/material.dart';
import 'package:zonzacar/providers/database_provider.dart';

class MisTrayectosScreen extends StatelessWidget {
   
  const MisTrayectosScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    DatabaseProvider databaseProvider = DatabaseProvider();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
                      MisReservasYPublicaciones(futureReservas: databaseProvider.getReservationsByUser()),
                      MisReservasYPublicaciones(futurePublicaciones: databaseProvider.getPublicationsByUser())
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
}

class MisReservasYPublicaciones extends StatelessWidget {
  const MisReservasYPublicaciones({
    super.key,
    this.futureReservas, this.futurePublicaciones,
  });

  final Future<dynamic>? futureReservas;
  final Future<dynamic>? futurePublicaciones;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureReservas ?? futurePublicaciones,
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data.length > 0) {
          List myList = snapshot.data;
          return ListView.separated(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              
              return futureReservas != null ? ListTile(
                title: Text(myList[index]['publicacion']),
                subtitle: Text(myList[index]['pasajero']),
              ) : ListTile(
                title: Text(myList[index]['origen']),
                subtitle: Text(myList[index]['destino']),
              );
            }, 
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          );
        } else if (snapshot.hasData && snapshot.data.length == 0) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                futureReservas != null ? const Text('No tienes reservas', style: TextStyle(fontSize: 25.0,  color: Colors.grey)) : Text('No tienes publicaciones', style: TextStyle(fontSize: 25.0,  color: Colors.grey)),
                const SizedBox(width: 10.0),
                const Icon(Icons.sentiment_dissatisfied_outlined, color: Colors.grey, size: 30.0,)
              ],
            )
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}