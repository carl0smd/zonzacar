
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zonzacar/providers/database_provider.dart';

Future<void> editarFotoDialog(BuildContext context, void Function(dynamic camara) uploadImage) {
    return showDialog(
      context: context,
      builder: (context) {
        if (defaultTargetPlatform ==  TargetPlatform.iOS) {
          return CupertinoAlertDialog(
          title: const Text('Selecciona una opción', textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextButton(
                  child: const Text('Cámara', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    uploadImage(true);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Galería', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    uploadImage(false);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
        } else {
          return AlertDialog(
            title: const Text('Selecciona una opción', textAlign: TextAlign.center,),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextButton(
                    child: const Text('Cámara', style: TextStyle(fontSize: 16),),
                    onPressed: () {
                      uploadImage(true);
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Galería', style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      uploadImage(false);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
        }
        
    );
  }

  Future<void> addVehicleDialog(BuildContext context, DatabaseProvider databaseProvider) {
    final formKey = GlobalKey<FormState>();
    final matriculaController = TextEditingController();
    final modeloController = TextEditingController();
    final colorController = TextEditingController();
    final marcaController = TextEditingController();

    return showDialog(
      context: context, 
      builder: (context) {

        if (defaultTargetPlatform ==  TargetPlatform.iOS) {
          return CupertinoAlertDialog(
          title: const Text('Añadir vehículo', textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: matriculaController,
                        decoration: const InputDecoration(
                          hintText: 'Matrícula',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Introduce una matrícula';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: marcaController,
                        decoration: const InputDecoration(
                          hintText: 'Marca',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Introduce una marca';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: modeloController,
                        decoration: const InputDecoration(
                          hintText: 'Modelo',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Introduce un modelo';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: colorController,
                        decoration: const InputDecoration(
                          hintText: 'Color',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Introduce un color';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(fontSize: 16, color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Añadir', style: TextStyle(fontSize: 16, color: Colors.green)),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await databaseProvider.saveVehicle(matriculaController.text.trim(), marcaController.text.trim(), modeloController.text.trim(), colorController.text.trim());
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
        }
         else {
          return AlertDialog(
            title: const Text('Añadir vehículo', textAlign: TextAlign.center,),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: matriculaController,
                          decoration: const InputDecoration(
                            hintText: 'Matrícula',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Introduce una matrícula';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: marcaController,
                          decoration: const InputDecoration(
                            hintText: 'Marca',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Introduce una marca';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: modeloController,
                          decoration: const InputDecoration(
                            hintText: 'Modelo',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Introduce un modelo';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: colorController,
                          decoration: const InputDecoration(
                            hintText: 'Color',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Introduce un color';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar', style: TextStyle(fontSize: 16, color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Añadir', style: TextStyle(fontSize: 16, color: Colors.green)),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await databaseProvider.saveVehicle(matriculaController.text.trim(), modeloController.text.trim(), colorController.text.trim(), marcaController.text.trim());
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        }
        
        
      }
    );

  }
  

