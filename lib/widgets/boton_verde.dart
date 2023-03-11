import 'package:flutter/material.dart';

class BotonVerde extends StatelessWidget {

  final String text;
  final void Function() onPressed;

  const BotonVerde({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(

      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
        shape: MaterialStatePropertyAll(StadiumBorder())
      ),
      onPressed: onPressed,
      child: Container(
        height: 55,
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 17),)
        )
      ),
    );
  }
}