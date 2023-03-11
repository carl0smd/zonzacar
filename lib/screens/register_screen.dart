
import 'package:flutter/cupertino.dart';
import 'package:zonzacar/helpers/helper_function.dart';
import 'package:zonzacar/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';

class RegisterScreen extends StatelessWidget {
   
  const RegisterScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Logo(titulo: 'Registro'),
                _Form(),
                const Labels(ruta: 'login', text: '¿Ya tienes cuenta?', gestureText: 'Accede desde aquí!'),
                const Text('Términos y condiciones de uso', style: TextStyle(fontWeight: FontWeight.w200),),
              ],
            ),
          ),
        ),
      )
    );
  }
}



class _Form extends StatefulWidget {

  const _Form({super.key});

  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String? nombre   = '';
  String? email    = '';
  String? password = '';

  AuthProvider authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: _isLoading ? CircularProgressIndicator() : Form(
        key: formKey,
        child: Column(
          children: [
            CustomInput(
              icon: Icons.perm_identity,
              placeholder: 'Nombre completo',
              onChanged: (value) {

                if (value != null) {
                  nombre = value;
                  setState(() {});
                }
              },
              validator: (value) {
                //regex for full name, the name and last name must be separated by a space and each name must have at least 2 characters
                return RegExp(r"^[A-Za-z]{2,}(?:\s[A-Za-z]{2,})+$").hasMatch(value!)
                ? null
                : 'Introduce al menos tu primer nombre y apellido';
              },
            ),
            CustomInput(
              icon: Icons.mail_outline,
              placeholder: 'Correo',
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
                setState(() {});
              },
              validator: (value) {
                return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!) 
                ? null 
                : 'Introduce un correo válido';
              },
            ),
            CustomInput(
              icon: Icons.lock_outline,
              placeholder: 'Contraseña',
              isPassword: true,
              onChanged: (value) {
                password = value;
                setState(() {});
              },
              validator: (value) {
                //la contraseña tener al menos  8 caracteres con al menos una letra mayúscula, una letra minúscula y un número y un caracter especial
                return RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_+:.]).{8,}$").hasMatch(value!)
                ? null
                : 'Mínimo 8 caracteres con una mayúscula, una minúscula, un número y un caracter especial';
              },
            ),
            BotonVerde (
              text: 'Crear cuenta', 
              onPressed: () {
                register(nombre, email, password);
              },
            )
          ],
        ),
      ),
    );
  }

  register(nombreCompleto, email, password) async {
    if (formKey.currentState!.validate()) {
      setState(() {});
      _isLoading = true;
      await authProvider.registerUser(nombreCompleto, email, password)
      .then((value) async {
        if (value == true) {
          showSnackbar('Usuario creado correctamente', context);
          if (context.mounted) Navigator.pushReplacementNamed(context, 'login');
        } else {
          showSnackbar(value, context);
          setState(() {});
          _isLoading = false; 
        }
      });
    }
  }
}

