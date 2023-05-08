import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/screens/screens.dart';
import 'package:zonzacar/widgets/widgets.dart';

import '../providers/database_provider.dart';

// SCREEN TO SHOW PUBLICATIONS RESULTS

class BusquedaScreen extends StatelessWidget {
  final String? origin;
  final String? destination;
  final int? date;
  final bool isGoingToZonzamas;

  const BusquedaScreen({
    Key? key,
    this.origin,
    this.destination,
    this.date,
    required this.isGoingToZonzamas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final databaseProvider = DatabaseProvider();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resultados',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'home',
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(size: 40, color: Colors.white),
      ),
      body: SafeArea(
        //FutureBuilder to get the publications
        child: FutureBuilder(
          future: isGoingToZonzamas
              ? date != null
                  ? databaseProvider.getPublicationsToZonzamas(date)
                  : databaseProvider.getPublicationsToZonzamas()
              : date != null
                  ? databaseProvider.getPublicationsFromZonzamas(date)
                  : databaseProvider.getPublicationsFromZonzamas(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data.length != 0) {
              final publications = snapshot.data;
              publications.removeWhere((element) =>
                  element['conductor'] ==
                      FirebaseAuth.instance.currentUser!.uid ||
                  element['pasajeros']
                      .contains(FirebaseAuth.instance.currentUser!.uid));
              origin != null
                  ? publications.removeWhere((element) =>
                      element['origen']
                          .toString()
                          .toLowerCase()
                          .contains(origin!.toLowerCase()) ==
                      false)
                  : destination != null
                      ? publications.removeWhere((element) =>
                          element['destino']
                              .toString()
                              .toLowerCase()
                              .contains(destination!.toLowerCase()) ==
                          false)
                      : null;
              return publications.length != 0
                  ?
                  //ListView to show the publications

                  Center(
                      child: ListView.builder(
                        itemCount: publications.length,
                        itemBuilder: (BuildContext context, int index) {
                          //FutureBuilder to get the user
                          return FutureBuilder(
                            future: databaseProvider.getUserByUid(
                              publications[index]['conductor'],
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final user = snapshot.data[0];
                                return BookingCard(
                                  publication: publications[index],
                                  userName: user['nombreCompleto'],
                                  userImage: user['imagenPerfil'],
                                  rating: user['mediaValoraciones'],
                                  isGoingToZonzamas: isGoingToZonzamas,
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                      ),
                    )
                  : const NoResults();
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

//Widget that shows a message when there are no results
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
            Text(
              'No existen trayectos que coincidan con tu búsqueda',
              style: TextStyle(fontSize: 18.0, color: Colors.green),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}

//Widget that shows a publication
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.publication,
    required this.userName,
    required this.userImage,
    required this.isGoingToZonzamas,
    required this.rating,
  });

  final dynamic publication;
  final String userName;
  final String userImage;
  final dynamic rating;
  final bool isGoingToZonzamas;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: ReservaDetailsScreen(
          id: publication['uid'],
          userImage: userImage,
          userName: userName,
          isGoingToZonzamas: isGoingToZonzamas,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 3,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Name of the user, image and rating
              Row(
                children: [
                  UserImage(
                    userImage: userImage,
                    radiusOutterCircle: 32,
                    radiusImageCircle: 30,
                    iconSize: 30,
                  ),
                  const SizedBox(width: 10.0),
                  SizedBox(
                    width: 120,
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  rating != 0
                      ? SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(Icons.star, color: Colors.green),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
              const SizedBox(height: 10.0),
              //Origin
              Text(
                publication['origen'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10.0),
              //Date, time and max passengers
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
                  Text(
                    DateFormat('dd/MM/yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        publication['fecha'],
                      ),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 10.0),
                  Text(
                    publication['horaSalida'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const Icon(Icons.people, color: Colors.green),
                  const SizedBox(width: 10.0),
                  Text(
                    '${publication['pasajeros'].length}/${publication['asientosDisponibles']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              //Destination
              const SizedBox(height: 10.0),
              Text(
                publication['destino'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10.0),
              //Button to book
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
                        isGoingToZonzamas: isGoingToZonzamas,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Reservar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
