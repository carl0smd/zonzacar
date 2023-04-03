import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../shared/constants.dart';

class FormularioTrayectoScreen extends StatelessWidget {

  final String distancia;
   
  const FormularioTrayectoScreen({Key? key, required this.distancia}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final fechaCtrl = TextEditingController();
    final horaCtrl = TextEditingController();
    final precioCtrl = TextEditingController();

    final precio = (
      double.parse(distancia.split(" ")[0]) 
      * PrecioConstants.precioPorKm 
      * PrecioConstants.porcentajeZonzaCar 
    ).toStringAsFixed(2);

    return Scaffold(
      body: SafeArea(
        child: Center(
           child: Container(
            margin: const EdgeInsets.all(20.0),
             child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Distancia: $distancia, Precio total: $precio',
                    style: const TextStyle(fontSize: 20.0, color: Colors.green),
                  
                  ),
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
                  

                  //TextField to pick price
                  TextField(
                    controller: precioCtrl,
                    maxLength: 5,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: 'Precio',
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