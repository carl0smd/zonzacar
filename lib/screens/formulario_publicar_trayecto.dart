import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zonzacar/widgets/snackbar.dart';

import '../providers/database_provider.dart';
import '../shared/constants.dart';

class FormularioTrayectoScreen extends StatefulWidget {
  final String distancia;
  final String origen;
  final String destino;
  final String coordenadasOrigen;
  final String coordenadasDestino;
  final String duracion;

  const FormularioTrayectoScreen({
    Key? key,
    required this.distancia,
    required this.origen,
    required this.destino,
    required this.coordenadasOrigen,
    required this.coordenadasDestino,
    required this.duracion,
  }) : super(key: key);

  @override
  State<FormularioTrayectoScreen> createState() =>
      _FormularioTrayectoScreenState();
}

class _FormularioTrayectoScreenState extends State<FormularioTrayectoScreen> {
  final databaseProvider = DatabaseProvider();
  final List vehicles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    databaseProvider.getVehicles().then((value) {
      setState(() {
        vehicles.addAll(value);
      });
    });
  }

  toDouble(hour, minute) {
    return hour + minute / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final fechaCtrl = TextEditingController();
    final horaCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final asientosCtrl = TextEditingController();
    int fecha = 0;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).millisecondsSinceEpoch;
    final hourNow = TimeOfDay(
      hour: DateTime.now().hour,
      minute: DateTime.now().minute,
    );
    final precio = (double.parse(widget.distancia.split(" ")[0]) *
            PrecioConstants.precioPorKm /
            4)
        .toStringAsFixed(2);
    dynamic vehiculo;
    int plazas = 4;
    asientosCtrl.text = plazas.toString();
    precioCtrl.text = precio;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Publicar trayecto',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(size: 40, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //Info del trayecto
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 10.0,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Origen
                        Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            widget.origen,
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //Linea vertical
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              width: 3.0,
                              height: 50.0,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10.0),
                            Icon(
                              Icons.directions_car,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10.0),
                            //Distancia
                            Text(
                              widget.distancia,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Icon(
                              Icons.timer_sharp,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10.0),
                            //Duración
                            Text(
                              widget.duracion,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        //Destino
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            widget.destino,
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  //Formulario
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Campo fecha
                        TextFormField(
                          controller: fechaCtrl,
                          maxLength: 10,
                          readOnly: true,
                          decoration: const InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(),
                            labelText: 'Fecha',
                            counterText: '',
                            fillColor: Colors.white,
                          ),
                          onTap: () async {
                            DateFormat dateFormat = DateFormat('dd/MM/yyyy');
                            DateTime? nuevaFecha = await showDatePicker(
                              context: context,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              //not on july and august and weekends
                              initialDate: FechaConstants.initialDate,
                              firstDate: FechaConstants.initialDate,
                              lastDate: FechaConstants.initialDate
                                  .add(const Duration(days: 365)),
                              selectableDayPredicate: (DateTime val) {
                                if (val.weekday == 6 || val.weekday == 7) {
                                  return false;
                                }
                                if (val.month == 7 || val.month == 8) {
                                  return false;
                                }
                                return true;
                              },
                            );
                            if (nuevaFecha == null) return;
                            fechaCtrl.text = dateFormat.format(nuevaFecha);
                            fecha = nuevaFecha.millisecondsSinceEpoch;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduce una fecha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        //Campo hora
                        TextFormField(
                          controller: horaCtrl,
                          maxLength: 5,
                          readOnly: true,
                          decoration: const InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(),
                            labelText: 'Hora',
                            counterText: '',
                            fillColor: Colors.white,
                          ),
                          onTap: () async {
                            TimeOfDay? nuevaHora = await showTimePicker(
                              context: context,
                              initialEntryMode: TimePickerEntryMode.dialOnly,
                              initialTime: TimeOfDay.now(),
                            );
                            if (nuevaHora == null) return;
                            if (mounted) {
                              horaCtrl.text = nuevaHora.format(context);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduce una hora';
                            } else if (today <= fecha &&
                                toDouble(hourNow.hour, hourNow.minute) >=
                                    toDouble(
                                      int.parse(
                                        value.split(':')[0],
                                      ),
                                      int.parse(
                                        value.split(':')[1],
                                      ),
                                    )) {
                              return 'Si el trayecto es hoy, la hora debe ser posterior a la actual';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 20.0),
                        //Campo vehiculo
                        DropdownButtonFormField(
                          items: vehicles.map((e) {
                            return DropdownMenuItem(
                              value: e['uid'],
                              child: Text(e['marca'] +
                                  ' ' +
                                  e['modelo'] +
                                  ' ' +
                                  e['matricula']),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(),
                            labelText: 'Vehiculo',
                            fillColor: Colors.white,
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

                        //Campo asientos
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
                                asientosCtrl.text =
                                    (int.parse(asientosCtrl.text) - 1)
                                        .toString();
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (int.parse(asientosCtrl.text) >= plazas) {
                                  return;
                                }
                                asientosCtrl.text =
                                    (int.parse(asientosCtrl.text) + 1)
                                        .toString();
                              },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduce el número de asientos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),

                        //Campo precio
                        TextFormField(
                          controller: precioCtrl,
                          maxLength: 5,
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            border: const OutlineInputBorder(),
                            labelText: 'Precio por pasajero',
                            helperText:
                                'Precio recomendado según coste medio de gasolina por km, podrás aumentarlo un máximo de 1€',
                            counterText: '',
                            helperMaxLines: 2,
                            prefixIcon: IconButton(
                              onPressed: () {
                                if (double.parse(precioCtrl.text) <=
                                        double.parse(precio) - 1 ||
                                    double.parse(precioCtrl.text) - 0.1 <= 0) {
                                  return;
                                }
                                precioCtrl.text =
                                    (double.parse(precioCtrl.text) - 0.1)
                                        .toStringAsFixed(2);
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (double.parse(precioCtrl.text) >=
                                    double.parse(precio) + 1) return;
                                precioCtrl.text =
                                    (double.parse(precioCtrl.text) + 0.1)
                                        .toStringAsFixed(2);
                              },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduce el precio';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20.0),

                        //Botón publicar
                        ElevatedButtonTheme(
                          data: ElevatedButtonThemeData(
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              elevation: 1,
                              minimumSize: const Size(double.infinity, 50),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      );
                                      try {
                                        await databaseProvider.savePublication(
                                          fecha,
                                          widget.duracion,
                                          widget.distancia,
                                          horaCtrl.text,
                                          widget.origen,
                                          widget.destino,
                                          widget.coordenadasOrigen,
                                          widget.coordenadasDestino,
                                          int.parse(asientosCtrl.text),
                                          double.parse(precioCtrl.text),
                                          vehiculo,
                                        );
                                        if (mounted) {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            'home',
                                            (route) => false,
                                          );
                                          showSnackbar(
                                            'Publicación creada correctamente',
                                            context,
                                          );
                                          isLoading = false;
                                        }
                                      } catch (e) {
                                        showSnackbar(e.toString(), context);
                                        isLoading = false;
                                        return;
                                      }
                                    }
                                  },
                            child: const Text(
                              'Publicar',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
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
