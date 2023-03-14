import 'package:flutter/material.dart';

class PublicacionesScreen extends StatefulWidget {
   
  const PublicacionesScreen({Key? key}) : super(key: key);

  @override
  State<PublicacionesScreen> createState() => _PublicacionesScreenState();
}

class _PublicacionesScreenState extends State<PublicacionesScreen> {

  final _goToZonzamasSearchController = TextEditingController();
  final _goFromZonzamasSearchController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
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
                Expanded(
                  child: TabBarView(
                    children: [
                      Column(
                        children: [
                          Container(                 
                            height: size.height * 0.38,
                            width:  double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/voy-al-centro.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          TextField(
                            controller: _goToZonzamasSearchController,
                            autofocus: false,
                            showCursor: false,
                            decoration: const InputDecoration(
                              hintText: 'Indica el lugar de salida...',
                              hintStyle: TextStyle(color: Colors.grey,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),

                            ),

                      
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(                 
                            height: size.height * 0.38,
                            width:  double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/voy-al-centro.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}