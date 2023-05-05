import 'package:flutter/material.dart';

class ImagenUsuario extends StatelessWidget {
  const ImagenUsuario({
    super.key,
    required this.userImage,
    required this.radiusOutterCircle,
    required this.radiusImageCircle,
    required this.iconSize,
  });

  final String userImage;
  final double radiusOutterCircle;
  final double radiusImageCircle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black87,
      radius: radiusOutterCircle,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: radiusImageCircle,
        child: userImage == '' || userImage.isEmpty
            ? Icon(
                Icons.person,
                size: iconSize,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  userImage,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
      ),
    );
  }
}
