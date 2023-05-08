import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/screens/screens.dart';

import '../shared/constants.dart';

// SCREEN TO LOOK FOR PUBLICATIONS
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
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(10.0),
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
      ),
    );
  }
}

// WIDGET TO SHOW THE SEARCH BOX

class _CajaDeBusqueda extends StatefulWidget {
  final Size size;

  const _CajaDeBusqueda({
    required this.size,
  });

  @override
  State<_CajaDeBusqueda> createState() => _CajaDeBusquedaState();
}

class _CajaDeBusquedaState extends State<_CajaDeBusqueda>
    with SingleTickerProviderStateMixin {
  final originCtrl = TextEditingController();
  final destinationCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  @override
  void dispose() {
    originCtrl.dispose();
    destinationCtrl.dispose();
    dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int date = 0;
    final formKey = GlobalKey<FormState>();
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          return Scaffold(
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
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TextFormField(
                          controller: originCtrl,
                          autofocus: false,
                          onChanged: (value) {
                            destinationCtrl.clear();
                          },
                          decoration: InputDecoration(
                            hintText: '¿Desde dónde sales? (opcional)',
                            prefixIcon: const Icon(Icons.fmd_good_outlined),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                originCtrl.clear();
                              },
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: destinationCtrl,
                          autofocus: false,
                          onChanged: (value) {
                            originCtrl.clear();
                          },
                          decoration: InputDecoration(
                            hintText: '¿Hacia dónde vas? (opcional)',
                            prefixIcon: const Icon(Icons.fmd_good_outlined),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                destinationCtrl.clear();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: dateCtrl,
                      maxLength: 10,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Fecha (opcional)',
                        prefixIcon: const Icon(Icons.calendar_month_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            dateCtrl.clear();
                          },
                        ),
                        counterText: '',
                      ),
                      onTap: () async {
                        DateFormat dateFormat = DateFormat('dd/MM/yyyy');
                        DateTime? nuevaFecha = await showDatePicker(
                          context: context,
                          //no editable
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          initialDate: DateConstants.initialDate,
                          firstDate: DateConstants.initialDate,
                          lastDate: DateConstants.initialDate
                              .add(const Duration(days: 365)),
                          selectableDayPredicate: (DateTime val) {
                            if (val.weekday == 6 || val.weekday == 7) {
                              return false;
                            }
                            if (val.month == 7 || val.month == 8) return false;
                            return true;
                          },
                        );

                        if (nuevaFecha == null) return;
                        dateCtrl.text = dateFormat.format(nuevaFecha);
                        date = nuevaFecha.millisecondsSinceEpoch;
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        withNavBar: false,
                        screen: DefaultTabController.of(context).index == 0
                            ? BusquedaScreen(
                                isGoingToZonzamas: true,
                                origin: originCtrl.text.trim() == ''
                                    ? null
                                    : originCtrl.text.trim(),
                                date: date != 0 ? date : null,
                              )
                            : BusquedaScreen(
                                isGoingToZonzamas: false,
                                destination: destinationCtrl.text.trim() == ''
                                    ? null
                                    : destinationCtrl.text.trim(),
                                date: date != 0 ? date : null,
                              ),
                      );
                      originCtrl.clear();
                      destinationCtrl.clear();
                      dateCtrl.clear();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(widget.size.width, 50.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('Buscar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
