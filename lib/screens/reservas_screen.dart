import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../shared/constants.dart';

class ReservasScreen extends StatelessWidget {
   
  const ReservasScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                height: size.height * 0.4,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/reservas.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                margin:  const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(10.0),
                height: size.height * 0.40,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: _CajaDeBusqueda(size: size),
              ),
            ],
          ),
        ),
      )
    );
  }
}

class _CajaDeBusqueda extends StatelessWidget {

  final Size size;

  const _CajaDeBusqueda({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {

    final origenCtrl = TextEditingController();
    final destinoCtrl = TextEditingController();
    final fechaCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(

        backgroundColor: Colors.white,
        body: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TabBar(
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green,
                tabs: [
                  Tab(text: 'Voy a clase'),
                  Tab(text: 'Salgo de clase'),
                ],
              ),
              const SizedBox(height: 30,),
              Expanded(
                child: TabBarView(
                  children: [
                    TextFormField(
                      controller: origenCtrl,
                      decoration: const InputDecoration(
                        hintText: '¿Desde dónde sales?',
                        prefixIcon: Icon(Icons.fmd_good_outlined),                      
                      ),
                    ),
                    TextFormField(
                      controller: destinoCtrl,
                      decoration: const InputDecoration(              
                        hintText: '¿Hacia dónde vas?',
                        prefixIcon: Icon(Icons.fmd_good_outlined),
                      ),
                    ),
                  ]
                )
              ),
              Expanded(
                child: TextFormField(
                  controller: fechaCtrl,
                  maxLength: 10,
                  readOnly: true,                   
                  decoration: const InputDecoration(
                    hintText: 'Fecha',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                    counterText: '',
                  ),
                      
                  onTap: () async {
                    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
                    DateTime? nuevaFecha = await showDatePicker(
                      context: context, 
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
                      return 'Por favor, ingrese una fecha';
                    }
                    return null;
                  },
                ),
              ),
        
              TextButton(
                onPressed: (){},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.white,
                  minimumSize: Size(size.width, 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ), 
                child: const Text('Buscar'),
              ),
        
              
            ],
          ),
        ),
      ),
    );
  }
}