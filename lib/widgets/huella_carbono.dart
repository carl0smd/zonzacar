import 'package:flutter/material.dart';

class HuellaCarbono extends StatelessWidget {
  const HuellaCarbono({super.key, required this.huellaCarbono});

  final double huellaCarbono;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Huella de carbono',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Text(
              '${huellaCarbono.toStringAsFixed(2)} kg CO2',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const Icon(
          Icons.eco,
          color: Colors.green,
          size: 40,
        ),
      ],
    );
  }
}
