
import 'package:flutter/material.dart';

void showSnackbar(String message, BuildContext context) {
  final snackbar = SnackBar(
    content: Text(message, style: const TextStyle(color: Colors.black)),
    backgroundColor: Colors.white,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    action: SnackBarAction(
      label: 'Ok',
      textColor: Colors.green,
      onPressed: () {},
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}