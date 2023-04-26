import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/screens/screens.dart';

import '../providers/database_provider.dart';

class BusquedaScreen extends StatelessWidget {

  final String? origen;
  final String? destino;
  final int? fecha;
  final bool isGoingToZonzamas;
   
  const BusquedaScreen({Key? key, this.origen, this.destino, this.fecha, required this.isGoingToZonzamas}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final databaseProvider = DatabaseProvider();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(size: 40, color: Colors.green),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: isGoingToZonzamas ? fecha != null 
          ? databaseProvider.getPublicationsToZonzamas(fecha) 
          : databaseProvider.getPublicationsToZonzamas() 
          : fecha != null ? databaseProvider.getPublicationsFromZonzamas(fecha) 
          : databaseProvider.getPublicationsFromZonzamas(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data.length != 0) {
              final publications = snapshot.data;
              publications.removeWhere((element) => element['conductor'] == FirebaseAuth.instance.currentUser!.uid);
              origen != null ? publications.removeWhere((element) => element['origen'].toString().toLowerCase().contains(origen!.toLowerCase()) == false) 
              : destino != null ? publications.removeWhere((element) => element['destino'].toString().toLowerCase().contains(destino!.toLowerCase()) == false)
              : null;
              return publications.length != 0 ?
              Center(
                child: ListView.builder(
                  itemCount: publications.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FutureBuilder(
                      future: databaseProvider.getUserByUid(publications[index]['conductor']),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final user = snapshot.data[0];
                          return BookingCard(publication: publications[index], userName: user['nombreCompleto'], userImage: user['imagenPerfil'],);
                        } else {
                          return Container();
                        }
                      }
                    );
                  },
                ),
              ) : const NoResults();
            } else if (snapshot.hasData && snapshot.data.length == 0) {
              return const NoResults();
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class NoResults extends StatelessWidget {
  const NoResults({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off, size: 80.0, color: Colors.green),
            SizedBox(height: 20.0),
            Text('No existen trayectos que coincidan con tu búsqueda', style: TextStyle(fontSize: 18.0, color: Colors.green), textAlign: TextAlign.justify,),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.publication, required this.userName, required this.userImage,
  });

  final dynamic publication;
  final String userName;
  final String userImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PersistentNavBarNavigator.pushNewScreen(
        context, 
        screen: ReservaDetailsScreen(
          id: publication['uid'],
          userImage: userImage,
          userName: userName,
        )
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
        ),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black87,
                    radius: 32,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: userImage == '' ? 
                      const Icon(Icons.person, size: 30,)
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(userImage, fit: BoxFit.cover, width: 100, height: 100,),
                      ),
                    )
                  ),
                  const SizedBox(width: 10.0),
                  Container(
                    width: 220,
                    child: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(publication['origen'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.grey[600])),
              const SizedBox(height: 10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    width: 3.0,
                    height: 50.0,
                    color: Colors.green,
                  ),
                  const Icon(Icons.calendar_today, color: Colors.green),
                  const SizedBox(width: 10.0),
                  Text(DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(publication['fecha'])), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                  const SizedBox(width: 10.0),
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 10.0),
                  Text(publication['horaSalida'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                  const SizedBox(width: 10.0),
                  //maximo de pasajeros
                  const Icon(Icons.person, color: Colors.green),
                  const SizedBox(width: 10.0),
                  Text(publication['asientosDisponibles'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(publication['destino'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.grey[600])),
              const SizedBox(height: 10.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context, 
                      screen: ReservaDetailsScreen(
                        id: publication['uid'],
                        userImage: userImage,
                        userName: userName,
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                  ), 
                  child: const Text('Reservar'),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}