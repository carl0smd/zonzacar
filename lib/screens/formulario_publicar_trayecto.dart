import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/database_provider.dart';
import '../shared/constants.dart';

class FormularioTrayectoScreen extends StatefulWidget {

  final String distancia;
  final String origen;
  final String destino;
  final String coordenadasOrigen;
  final String coordenadasDestino;

  const FormularioTrayectoScreen({Key? key, required this.distancia, required this.origen, required this.destino, required this.coordenadasOrigen, required this.coordenadasDestino}) : super(key: key);

  @override
  State<FormularioTrayectoScreen> createState() => _FormularioTrayectoScreenState();
}

class _FormularioTrayectoScreenState extends State<FormularioTrayectoScreen> {
  
  final databaseProvider = DatabaseProvider();
  final List vehicles = [];

  @override
  void initState() {
    super.initState();
    databaseProvider.getVehicles().then((value) {
      setState(() {
        vehicles.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final fechaCtrl = TextEditingController();
    final horaCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final plazasCtrl = TextEditingController();
    final precio = (
      double.parse(widget.distancia.split(" ")[0]) 
      * PrecioConstants.precioPorKm 
    ).toStringAsFixed(2);
    dynamic vehicle;
    String plazas = '4';
    plazasCtrl.text = plazas;
    return Scaffold(
      body: SafeArea(
        child: Center(
           child: Container(
            margin: const EdgeInsets.all(20.0),
             child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Distancia: ${widget.distancia}',
                    style: const TextStyle(fontSize: 20.0, color: Colors.green, ), textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20.0),

                  TextField(
                    controller: fechaCtrl,
                    maxLength: 10,
                    readOnly: true,
                    
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: 'Fecha',
                      counterText: '',
                      fillColor: Colors.white
                    ),
                    onTap: () async {
                      DateFormat dateFormat = DateFormat('dd/MM/yyyy');
                      DateTime? nuevaFecha = await showDatePicker(
                        context: context,  
                        //not on july and august and weekends
                        selectableDayPredicate: (DateTime val) {
                          if (val.weekday == 6 || val.weekday == 7) return false;
                          if (val.month == 7 || val.month == 8) return false;
                          return true;
                        },
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                 
                      if (nuevaFecha == null) return;
                      fechaCtrl.text = dateFormat.format(nuevaFecha);
                    },
                  ),
                  const SizedBox(height: 20.0),
                  //TextField to pick time
                  TextField(
                    controller: horaCtrl,
                    maxLength: 5,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: 'Hora',
                      counterText: '',
                      fillColor: Colors.white
                    ),
                    onTap: () async {
                      TimeOfDay? nuevaHora = await showTimePicker(
                        context: context, 
                        initialTime: TimeOfDay.now(),
                      );
                      if (nuevaHora == null) return;
                      horaCtrl.text = nuevaHora.format(context);
                    },
                  ),

                  const SizedBox(height: 20.0),

                  DropdownButtonFormField(
                    items: vehicles.map((e) {
                      return DropdownMenuItem(
                        value: e['uid'],
                        child: Text(e['marca'] + ' ' + e['modelo'] + ' ' + e['matricula']),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: 'Vehiculo',
                      fillColor: Colors.white
                    ),
                    
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        vehicle = vehicles.firstWhere((element) => element['uid'] == value);
                        print(vehicle);
                        plazas = vehicle['plazas'].toString();
                        print(plazas);
                        plazasCtrl.text = plazas;
                      });
                      
                    },
                  ),
                  
                  const SizedBox(height: 20.0),

                  //TextField to pick seats
                  TextField(                    
                    controller: plazasCtrl,
                    maxLength: 1,
                    readOnly: true,
                    
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: 'Plazas',
                      counterText: '',
                      prefixIcon: IconButton(
                        onPressed: () {
                          if (int.parse(plazasCtrl.text) <= 1) return;
                          plazasCtrl.text = (int.parse(plazasCtrl.text) - 1).toString();
                        }, 
                        icon: const Icon(Icons.remove_circle_outline)
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (int.parse(plazasCtrl.text) >= int.parse(plazas)) return;
                          plazasCtrl.text = (int.parse(plazasCtrl.text) + 1).toString();
                        }, 
                        icon: const Icon(Icons.add_circle_outline)
                      ),
                      fillColor: Colors.white
                    ),
                    onTap: () {
                      print(plazasCtrl.text);
                    },
                  ),
                  

                  //TextField to pick price
                  vehicle != null ? TextField(
                    controller: precioCtrl,
                    maxLength: 5,
                    readOnly: true,
                    
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: 'Precio total',
                      counterText: '',
                      prefixIcon: IconButton(
                        onPressed: () {
                          if (double.parse(precioCtrl.text) <= double.parse(precio) - 2 || double.parse(precioCtrl.text) - 0.5 <= 0) return;
                          precioCtrl.text = (double.parse(precioCtrl.text) - 0.5).toStringAsFixed(2);
                        }, 
                        icon: const Icon(Icons.remove_circle_outline)
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (double.parse(precioCtrl.text) >= double.parse(precio) + 2) return;
                          precioCtrl.text = (double.parse(precioCtrl.text) + 0.5).toStringAsFixed(2);
                        }, 
                        icon: const Icon(Icons.add_circle_outline)
                      ),
                      fillColor: Colors.white
                    ),
                    onTap: () async {
                      TimeOfDay? nuevaHora = await showTimePicker(
                        context: context, 
                        initialTime: TimeOfDay.now(),
                      );
                      if (nuevaHora == null) return;
                      horaCtrl.text = nuevaHora.format(context);
                    },
                  ) : Container(),

                  const SizedBox(height: 20.0),

                  


                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    }, 
                    child: const Text('Publicar'),
                  ),
                 
                ],
             ),
           ),
        ),
      ),
    );
  }
}