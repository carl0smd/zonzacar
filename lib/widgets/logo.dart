import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final String title;

  const Logo({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(top: 20, bottom: 0),
        child: Column(
          children: [
            const Image(
              image: AssetImage('assets/logo.png'),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
