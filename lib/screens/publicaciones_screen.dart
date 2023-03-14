import 'package:flutter/material.dart';

class PublicacionesScreen extends StatelessWidget {
   
  const PublicacionesScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Container(
                margin: const EdgeInsets.only(top: 20.0),
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
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Voy al centro'),
                    ),
                    const Divider( height: 20, thickness: 1,),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Salgo del centro'),
                    ),
                  ],
                ),
              )
              
            ],
          ),
        ),
      ),
    );
  }
}