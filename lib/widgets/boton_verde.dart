import 'package:flutter/material.dart';

class CredentialsGreenButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  const CredentialsGreenButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
        shape: const MaterialStatePropertyAll(StadiumBorder()),
      ),
      onPressed: onPressed,
      child: SizedBox(
        height: 55,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ),
    );
  }
}
