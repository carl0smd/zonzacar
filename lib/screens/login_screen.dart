import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../helpers/helper_function.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
   
  const LoginScreen({Key? key}) : super(key: key);
  
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
              children: const [
                Logo(titulo: 'Acceso'),
                _Form(),
                Labels(ruta: 'register', text: '¿No tienes cuenta?', gestureText: 'Crea una ahora!'),
                Text('Términos y condiciones de uso', style: TextStyle(fontWeight: FontWeight.w200),),
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
  String? email = '';
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
            BotonVerde(
              text: 'Acceder', 
              onPressed: () {
                login(email, password);
                // Navigator.pushReplacementNamed(context, 'home');
              },
            )
          ],
        ),
      ),
    );
  }

  login(email, password) async {
    if (formKey.currentState!.validate()) {
      setState(() {});
      _isLoading = true;
      await authProvider.loginUser(email, password)
      .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =await DatabaseProvider(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);

          //saving shared preference state
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['nombreCompleto']);
          await HelperFunctions.saveUserEmailSF(email);
          if (context.mounted) Navigator.pushReplacementNamed(context, 'home');
        } else {
          showSnackbar(value, context);
          setState(() {});
          _isLoading = false; 
        }
      });
    }
  }
}

