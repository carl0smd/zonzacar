import 'package:flutter/material.dart';

// WIDGET TO SHOW A CUSTOM INPUT
class CustomInput extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final TextInputType keyboardType;
  final bool isPassword;
  final void Function(String?) onChanged;
  final String? Function(String?) validator;

  const CustomInput({
    super.key,
    required this.icon,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        autocorrect: false,
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black38),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          hintText: placeholder,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorMaxLines: 3,
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
