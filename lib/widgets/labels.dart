import 'package:flutter/material.dart';

// WIDGET FOR LABELS IN LOGIN AND REGISTER SCREENS
class Labels extends StatelessWidget {
  final String route;
  final String text;
  final String gestureText;

  const Labels({
    super.key,
    required this.route,
    required this.text,
    required this.gestureText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, route);
            },
            child: Text(
              gestureText,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
