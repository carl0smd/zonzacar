
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/shared/constants.dart';

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
    String color = '';
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: matriculaController,
                          decoration: const InputDecoration(
                            hintText: 'Matrícula',
                          ),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Introduce una matrícula';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: marcaController,
                          decoration: const InputDecoration(
                            hintText: 'Marca',
                          ),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Introduce una marca';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          controller: modeloController,
                          decoration: const InputDecoration(
                            hintText: 'Modelo',
                          ),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Introduce un modelo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10.0),
                        DropdownButtonFormField(
                          items: ColoresConstants.colores.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            color = value.toString();
                          },
                          decoration: const InputDecoration(
                            hintText: 'Color',
                            border:  OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Elije un color';
                            }
                            return null;
                          }
                        )
                      ],
                    ),
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
                  await databaseProvider.saveVehicle(
                    matriculaController.text.trim(), 
                    marcaController.text.trim(), 
                    modeloController.text.trim(), 
                    color
                  );
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: matriculaController,
                            decoration: const InputDecoration(
                              hintText: 'Matrícula',
                            ),
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Introduce una matrícula';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            controller: marcaController,
                            decoration: const InputDecoration(
                              hintText: 'Marca',
                            ),
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Introduce una marca';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            controller: modeloController,
                            decoration: const InputDecoration(
                              hintText: 'Modelo',
                            ),
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Introduce un modelo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10.0),
                          DropdownButtonFormField(
                            items: ColoresConstants.colores.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              color = value.toString();
                            },
                            decoration: const InputDecoration(
                              hintText: 'Color',
                              border:  OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Elije un color';
                              }
                              return null;
                            }
                          )
                        ],
                      ),
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
                    await databaseProvider.saveVehicle(
                      matriculaController.text.trim(), 
                      marcaController.text.trim(), 
                      modeloController.text.trim(), 
                      color
                    );
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
  

