import 'package:flutter/material.dart';

import '../providers/database_provider.dart';

class BusquedaScreen extends StatelessWidget {

  final String? origen;
  final String? destino;
  final String? fecha;
  final bool isGoingToZonzamas;
   
  const BusquedaScreen({Key? key, this.origen, this.destino, this.fecha, required this.isGoingToZonzamas}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final databaseProvider = DatabaseProvider();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar trayecto', style: TextStyle(color: Colors.black)),
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
            if (snapshot.hasData) {
              final publications = snapshot.data;
              origen != null ? publications.removeWhere((element) => element['origen'].toString().toLowerCase().contains(origen!.toLowerCase()) == false) 
              : destino != null ? publications.removeWhere((element) => element['destino'].toString().toLowerCase().contains(destino!.toLowerCase()) == false)
              : null;
      
              return publications.length != 0 ?
              Center(
                child: ListView.builder(
                  itemCount: publications.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(publications[index]['origen']),
                      subtitle: Text(publications[index]['destino']),
                    );
                  },
                ),
              ) : Center(
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
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
          
         
          
      
        ),
      ),
    );
  }
}