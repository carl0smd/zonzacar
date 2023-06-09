import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zonzacar/widgets/snackbar.dart';

import '../providers/database_provider.dart';
import '../shared/constants.dart';

// SCREEN TO SHOW THE FORM TO PUBLISH A TRIP

class FormularioTrayectoScreen extends StatefulWidget {
  final String distance;
  final String origin;
  final String destination;
  final String coordsOrigin;
  final String coordsDestination;
  final String duration;

  const FormularioTrayectoScreen({
    Key? key,
    required this.distance,
    required this.origin,
    required this.destination,
    required this.coordsOrigin,
    required this.coordsDestination,
    required this.duration,
  }) : super(key: key);

  @override
  State<FormularioTrayectoScreen> createState() =>
      _FormularioTrayectoScreenState();
}

class _FormularioTrayectoScreenState extends State<FormularioTrayectoScreen> {
  final databaseProvider = DatabaseProvider();
  final List vehicles = [];
  bool isLoading = false;
  final dateCtrl = TextEditingController();
  final hourCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final seatsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    databaseProvider.getVehicles().then((value) {
      setState(() {
        vehicles.addAll(value);
      });
    });
  }

  // FUNCTION TO CONVERT THE DATE AND HOUR TO A TIMESTAMP

  toDouble(hour, minute) {
    return hour + minute / 60.0;
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    int date = 0;
    int hour = 0;
    double carbonFootprint = 0;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).millisecondsSinceEpoch;
    final hourNow = TimeOfDay(
      hour: DateTime.now().hour,
      minute: DateTime.now().minute,
    );
    final price = (double.parse(widget.distance.split(" ")[0]) *
            PriceConstants.pricePerKm /
            4)
        .toStringAsFixed(2);
    dynamic vehicle;
    int seats = 4;
    seatsCtrl.text = seats.toString();
    priceCtrl.text = price;
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
                  //INFO DEL TRAYECTO
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
                        //ORIGIN
                        Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            widget.origin,
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
                            //VERTICAL LINE
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
                            //DISTANCE
                            Text(
                              widget.distance,
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
                            //DURATION
                            Text(
                              widget.duration,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        //DESTINATION
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            widget.destination,
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
                  //FORM
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //DATE PICKER
                        TextFormField(
                          controller: dateCtrl,
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
                            DateTime? newDate = await showDatePicker(
                              context: context,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              initialDate: DateConstants.initialDate,
                              firstDate: DateConstants.initialDate,
                              lastDate: DateConstants.initialDate
                                  .add(const Duration(days: 365)),
                              selectableDayPredicate: (DateTime val) {
                                //DISABLE WEEKENDS AND SUMMER
                                if (val.weekday == 6 || val.weekday == 7) {
                                  return false;
                                }
                                if (val.month == 7 || val.month == 8) {
                                  return false;
                                }
                                return true;
                              },
                            );
                            if (newDate == null) return;
                            dateCtrl.text = dateFormat.format(newDate);
                            date = newDate.millisecondsSinceEpoch;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduce una fecha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        //TIME PICKER
                        TextFormField(
                          controller: hourCtrl,
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
                            TimeOfDay? newHour = await showTimePicker(
                              context: context,
                              initialEntryMode: TimePickerEntryMode.dialOnly,
                              initialTime: TimeOfDay.now(),
                            );
                            if (newHour == null) return;
                            if (mounted) {
                              hourCtrl.text = newHour.format(context);
                              hour = newHour.hour * 3600000 +
                                  newHour.minute * 60000;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduce una hora';
                            } else if (today >= date &&
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
                        //VEHICLE PICKER
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
                            vehicle = value;
                            //check combustible and do a switch
                            vehicles.forEach((element) {
                              if (element['uid'] == value) {
                                switch (element['combustible']) {
                                  case 'Gasolina':
                                    {
                                      carbonFootprint =
                                          FuelConstants.emitions['gasolina']! *
                                              double.parse(
                                                widget.distance.split(' ')[0],
                                              );
                                      break;
                                    }
                                  case 'Diésel':
                                    {
                                      carbonFootprint =
                                          FuelConstants.emitions['diesel']! *
                                              double.parse(
                                                widget.distance.split(' ')[0],
                                              );
                                      break;
                                    }
                                  case 'Híbrido':
                                    {
                                      carbonFootprint =
                                          FuelConstants.emitions['hibrido']! *
                                              double.parse(
                                                widget.distance.split(' ')[0],
                                              );
                                      break;
                                    }
                                  case 'Eléctrico':
                                    {
                                      carbonFootprint =
                                          FuelConstants.emitions['electrico']! *
                                              double.parse(
                                                widget.distance.split(' ')[0],
                                              );
                                      break;
                                    }
                                }
                              }
                            });
                            print(carbonFootprint);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor, selecciona un vehiculo';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20.0),

                        //FIELD FOR SEATS
                        TextFormField(
                          controller: seatsCtrl,
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
                                if (int.parse(seatsCtrl.text) <= 1) return;
                                seatsCtrl.text =
                                    (int.parse(seatsCtrl.text) - 1).toString();
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (int.parse(seatsCtrl.text) >= seats) {
                                  return;
                                }
                                seatsCtrl.text =
                                    (int.parse(seatsCtrl.text) + 1).toString();
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

                        //PRICE FIELD
                        TextFormField(
                          controller: priceCtrl,
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
                                if (double.parse(priceCtrl.text) <=
                                        double.parse(price) - 1 ||
                                    double.parse(priceCtrl.text) - 0.1 <= 0) {
                                  return;
                                }
                                priceCtrl.text =
                                    (double.parse(priceCtrl.text) - 0.1)
                                        .toStringAsFixed(2);
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (double.parse(priceCtrl.text) >=
                                    double.parse(price) + 1) return;
                                priceCtrl.text =
                                    (double.parse(priceCtrl.text) + 0.1)
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

                        //BUTTON TO PUBLISH
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
                                          //DATE + HOUR IN MILLISECONDS TO GET FINAL DATE
                                          date + hour,
                                          widget.duration,
                                          widget.distance,
                                          hourCtrl.text,
                                          widget.origin,
                                          widget.destination,
                                          widget.coordsOrigin,
                                          widget.coordsDestination,
                                          int.parse(seatsCtrl.text),
                                          carbonFootprint,
                                          double.parse(priceCtrl.text),
                                          vehicle,
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
