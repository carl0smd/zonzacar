
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> editarFotoDialog(BuildContext context, void Function(dynamic camara) uploadImage) {
    return showDialog(
      context: context,
      builder: (context) {
        if (Platform.isAndroid) {
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
      }
    );
  }

