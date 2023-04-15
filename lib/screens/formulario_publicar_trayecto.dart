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

  const FormularioTrayectoScreen(
      {Key? key,
      required this.distancia,
      required this.origen,
      required this.destino,
      required this.coordenadasOrigen,
      required this.coordenadasDestino})
      : super(key: key);

  @override
  State<FormularioTrayectoScreen> createState() =>
      _FormularioTrayectoScreenState();
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
    final formKey = GlobalKey<FormState>();
    final fechaCtrl = TextEditingController();
    final horaCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final asientosCtrl = TextEditingController();
    final precio = (double.parse(widget.distancia.split(" ")[0]) * 
    PrecioConstants.precioPorKm).toStringAsFixed(2);
    dynamic vehiculo;
    String plazas = '4';
    asientosCtrl.text = plazas;
    precioCtrl.text = precio;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar trayecto', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(size: 40, color: Colors.green),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Distancia: ${widget.distancia}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20.0),

                  TextFormField(
                    controller: fechaCtrl,
                    maxLength: 10,
                    readOnly: true,
                    decoration: const InputDecoration(
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
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                        //not on july and august and weekends
                        initialDate: FechaConstants.initialDate,
                        firstDate: FechaConstants.initialDate,
                        lastDate: FechaConstants.initialDate.add(const Duration(days: 365)),
                        selectableDayPredicate: (DateTime val) {
                          if (val.weekday == 6 || val.weekday == 7) return false;
                          if (val.month == 7 || val.month == 8) return false;
                          return true;
                        },
                      );

                      if (nuevaFecha == null) return;
                      fechaCtrl.text = dateFormat.format(nuevaFecha);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce una fecha';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  //TextFormField to pick time
                  TextFormField(
                    controller: horaCtrl,
                    maxLength: 5,
                    readOnly: true,
                    decoration: const InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: 'Hora',
                      counterText: '',
                      fillColor: Colors.white
                    ),
                    onTap: () async {
                      TimeOfDay? nuevaHora = await showTimePicker(
                        context: context,
                        initialEntryMode: TimePickerEntryMode.dialOnly,
                        initialTime: TimeOfDay.now(),
                      );
                      if (nuevaHora == null) return;
                      if (mounted) horaCtrl.text = nuevaHora.format(context);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce una hora';
                      }
                      return null;
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
                      vehiculo = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecciona un vehiculo';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20.0),

                  //TextFormField to pick seats
                  TextFormField(
                    controller: asientosCtrl,
                    maxLength: 1,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      border: const OutlineInputBorder(),
                      labelText: 'Asientos disponibles',
                      helperText: 'Máximo 4 por motivos de seguridad',
                      counterText: '',
                      prefixIcon: IconButton(
                        onPressed: () {
                          if (int.parse(asientosCtrl.text) <= 1) return;
                          asientosCtrl.text = (int.parse(asientosCtrl.text) - 1).toString();
                        },
                        icon: const Icon(Icons.remove_circle_outline)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (int.parse(asientosCtrl.text) >= int.parse(plazas)) return;
                          asientosCtrl.text = (int.parse(asientosCtrl.text) + 1).toString();
                        },
                        icon: const Icon(Icons.add_circle_outline)),
                      fillColor: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce el número de asientos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),

                  //TextFormField to pick price
                  TextFormField(
                    controller: precioCtrl,
                    maxLength: 5,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      border: const OutlineInputBorder(),
                      labelText: 'Precio total (a dividir entre todos los pasajeros)',
                      helperText: 'Precio recomendado según coste medio de gasolina por km, podrás aumentarlo un máximo de 2€',
                      counterText: '',
                      helperMaxLines: 2,
                      prefixIcon: IconButton(
                        onPressed: () {
                          if (double.parse(precioCtrl.text) <= double.parse(precio) - 2 || double.parse(precioCtrl.text) - 0.5 <= 0) return;
                          precioCtrl.text = (double.parse(precioCtrl.text) - 0.5).toStringAsFixed(2);
                        },
                        icon: const Icon(Icons.remove_circle_outline)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (double.parse(precioCtrl.text) >= double.parse(precio) + 2) return;
                          precioCtrl.text = (double.parse(precioCtrl.text) + 0.5).toStringAsFixed(2);
                        },
                        icon: const Icon(Icons.add_circle_outline)),
                      fillColor: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce el precio';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20.0),

                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await databaseProvider.savePublication(
                          fechaCtrl.text,
                          horaCtrl.text,
                          widget.origen,
                          widget.destino,
                          widget.coordenadasOrigen,
                          widget.coordenadasDestino,
                          asientosCtrl.text,
                          precioCtrl.text,
                          vehiculo,
                        );
                        if (mounted) Navigator.pushReplacementNamed(context, 'home');
                      }
                    },
                    child: const Text('Publicar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
