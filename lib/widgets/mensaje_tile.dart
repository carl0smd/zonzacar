import 'package:flutter/material.dart';

class MensajeTile extends StatelessWidget {
  const MensajeTile({
    super.key,
    required this.mensaje,
    required this.emisor,
    required this.enviadoPorMi,
    required this.hora,
  });

  final String mensaje;
  final String emisor;
  final bool enviadoPorMi;
  final String hora;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: 24,
        right: 24,
      ),
      alignment: enviadoPorMi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: enviadoPorMi
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding: const EdgeInsets.only(
          top: 17,
          bottom: 17,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: enviadoPorMi
              ? const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23),
                ),
          color: enviadoPorMi ? Colors.green[400] : Colors.blue[300],
        ),
        child: Column(
          crossAxisAlignment:
              enviadoPorMi ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              hora,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              mensaje,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
