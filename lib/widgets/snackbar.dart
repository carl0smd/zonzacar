
import 'package:flutter/material.dart';

void showSnackbar(String message, BuildContext context) {
  final snackbar = SnackBar(
    content: Text(message, style: const TextStyle(color: Colors.black)),
    backgroundColor: Colors.white,
    action: SnackBarAction(
      label: 'Ok',
      textColor: Colors.green,
      onPressed: () {},
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}