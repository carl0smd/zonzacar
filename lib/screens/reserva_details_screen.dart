import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/widgets/snackbar.dart';

class ReservaDetailsScreen extends StatefulWidget {

  final String id;
  final String userImage;
  final String userName;
   
  const ReservaDetailsScreen({Key? key, required this.id, required this.userName, required this.userImage}) : super(key: key);

  @override
  State<ReservaDetailsScreen> createState() => _ReservaDetailsScreenState();
}

class _ReservaDetailsScreenState extends State<ReservaDetailsScreen> {

  @override
  Widget build(BuildContext context) {
    DatabaseProvider databaseProvider = DatabaseProvider();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del trayecto', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(size: 40, color: Colors.green),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: databaseProvider.getPublications(widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final publication = snapshot.data[0];
              return Column(
                children: [             
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(publication['fecha'])), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),),
                            const SizedBox(height: 10,),
                            Text(publication['horaSalida']+'h', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),),
                            const SizedBox(height: 10,),
                          ],
                        ),
                        const SizedBox(height: 40,),
                        Text(publication['origen'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 10,),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          width: 3.0,
                          height: 50.0,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 10,),
                        Text(publication['destino'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  Container (
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          const Text('Precio para un pasajero' , style: TextStyle(fontSize: 20),),
                          Text(publication['precio']+' €', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),),
                      ],
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 250,
                              child: Text(
                                widget.userName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.black87,
                              radius: 42,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 40,
                                child: widget.userImage == '' ? 
                                const Icon(Icons.person, size: 40,)
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.network(widget.userImage, fit: BoxFit.cover, width: 100, height: 100,),
                                ),
                              )
                            ),
                          ]
                        ),
                        const SizedBox(height: 20,),
                        SizedBox(height: 1, width: double.infinity, child: Container(color: Colors.black26,),),
                        const SizedBox(height: 20,),
                        FutureBuilder(
                          future: databaseProvider.getVehicleByUid(publication['vehiculo']),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final vehicle = snapshot.data[0];
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [ 
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(vehicle['marca'].toUpperCase()+' '+vehicle['modelo'].toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87 ),),
                                      const SizedBox(height: 5,),
                                      Text(vehicle['color'], style: const TextStyle(fontSize: 20),),
                                      
                                    ],
                                  ),
                                  const Icon(
                                    Icons.directions_car,
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                ],
                              );
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          }
                        ),
                        const SizedBox(height: 20,),
                        SizedBox(height: 1, width: double.infinity, child: Container(color: Colors.black26,),),
                        const SizedBox(height: 30,),
                        ElevatedButtonTheme(
                          data: ElevatedButtonThemeData(
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              elevation: 1,
                              minimumSize: const Size(double.infinity, 50),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context, 
                                builder: (BuildContext context) => buildSheet(databaseProvider)
                              );
                            },
                            child: const Text('Continuar', style: TextStyle(fontSize: 20),),
                          ),
                        )
                      ],
                    ),
                  ),
                  
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }
        ),
      )
    );
  }
  
  buildSheet(DatabaseProvider databaseProvider) {
    return Container(
      //pay with card, cash or cancel
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Método de pago', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  }, 
                  icon: const Icon(Icons.close, color: Colors.red, size: 30,)
                ),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          const Divider( height: 1, thickness: 1,),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return ListTile(
                    leading: const Icon(Icons.money, color: Colors.green, size: 30,),
                    title: const Text('Efectivo', style: TextStyle(fontSize: 18),),
                    trailing:  const Icon(Icons.arrow_forward_ios, color: Colors.green,),
                    onTap: () async {
                      try {
                        await databaseProvider.saveReservation(widget.id, FirebaseAuth.instance.currentUser!.uid);
                        await databaseProvider.addPassengerToPublication(widget.id, FirebaseAuth.instance.currentUser!.uid);
                        if (mounted) {
                          showSnackbar('Viaje reservado correctamente', context);
                          Navigator.pushReplacementNamed(context, 'home');
                        }
                      } catch (e) {
                        showSnackbar('Error al reservar el viaje', context);
                      }

                    },
                  );
                } else {
                  return ListTile(
                    leading: const Icon(Icons.credit_card, color: Colors.grey, size: 30,),
                    title: const Text('Tarjeta de crédito/débito (Próximamente)', style: TextStyle(fontSize: 18, color: Colors.grey),),
                    trailing:  const Icon(Icons.arrow_forward_ios, color: Colors.grey,),
                    onTap: () {},
                  );
                }
              },           
            ),
          ),
        ],
      )
    );
  }
}

