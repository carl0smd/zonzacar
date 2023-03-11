import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                margin:  const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(20.0),
                height: size.height * 0.35,
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
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {

    final origenCtrl = TextEditingController();
    final destinoCtrl = TextEditingController();
    final fechaCtrl = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextField(
          controller: origenCtrl,
          decoration: InputDecoration(
            hintText: 'Origen',
            prefixIcon: Icon(Icons.fmd_good_outlined),                      
          ),
        ),

        TextField(
          controller: destinoCtrl,
          decoration: InputDecoration(              
            hintText: 'Destino',
            prefixIcon: Icon(Icons.fmd_good_outlined),
          ),
        ),
        
        TextField(
          controller: fechaCtrl,
          maxLength: 10,
          readOnly: true,                   
          decoration: InputDecoration(
            hintText: 'Fecha',
            prefixIcon: Icon(Icons.calendar_month_outlined),
            counterText: '',
          ),

          onTap: () async {
            DateFormat dateFormat = DateFormat('dd/MM/yyyy');
            DateTime? nuevaFecha = await showDatePicker(
              context: context, 
              initialDate: DateTime.now(), 
              firstDate: DateTime.now(), 
              lastDate: DateTime.now().add(const Duration(days: 30)) 
            );

            if (nuevaFecha == null) return;
            fechaCtrl.text = dateFormat.format(nuevaFecha);
          },
        ),

        TextButton(
          onPressed: (){}, 
          child: Text('Buscar'),
          style: TextButton.styleFrom(
            backgroundColor: Colors.green[400],
            foregroundColor: Colors.white,
            minimumSize: Size(size.width, 50.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),

        
      ],
    );
  }
}