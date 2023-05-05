import 'package:flutter/cupertino.dart';
import 'package:zonzacar/widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'dart:io' show Platform;

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Logo(titulo: 'Registro'),
                _Form(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String? nombre = '';
  String? email = '';
  String? password = '';

  AuthProvider authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: _isLoading
          ? const CircularProgressIndicator()
          : Column(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CustomInput(
                        icon: Icons.perm_identity,
                        placeholder: 'Nombre',
                        onChanged: (value) {
                          nombre = value;
                          setState(() {});
                        },
                        validator: (value) {
                          //regex unlimited names, separated by space, accentuation allowed and ñ, first name atleast 3 characters
                          return RegExp(
                            r"^(?=.{3,}$)[a-zA-ZÀ-ÿ\u00f1\u00d1]+(?:\s[a-zA-ZÀ-ÿ\u00f1\u00d1]+)*$",
                          ).hasMatch(value!.trim())
                              ? null
                              : 'Introduce un nombre válido, mínimo 3 caracteres';
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
                          return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(value!.trim())
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
                          //la contraseña tener al menos 6 caracteres sin espacios
                          return RegExp(r"^\S{6,}$").hasMatch(value!)
                              ? null
                              : 'La contraseña debe tener al menos 6 caracteres sin espacios';
                        },
                      ),
                      BotonVerde(
                        text: 'Crear cuenta',
                        onPressed: () {
                          register(nombre, email, password);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                const Labels(
                  ruta: 'login',
                  text: '¿Ya tienes cuenta?',
                  gestureText: 'Accede desde aquí!',
                ),
                // const SizedBox(height: 40,),
                // const Text('Términos y condiciones de uso', style: TextStyle(fontWeight: FontWeight.w200),),
              ],
            ),
    );
  }

  register(nombreCompleto, email, password) async {
    if (formKey.currentState!.validate()) {
      setState(() {});
      _isLoading = true;
      await authProvider
          .registerUser(nombreCompleto, email, password)
          .then((value) async {
        if (value == true) {
          await authProvider.sendEmailVerification();
          if (mounted) await _verificarEmailDialog(context);
          setState(() {});
          _isLoading = false;
          if (mounted) Navigator.pushReplacementNamed(context, 'login');
        } else {
          showSnackbar('Esta cuenta de correo ya existe', context);
          setState(() {});
          _isLoading = false;
        }
      });
    }
  }
}

Future _verificarEmailDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      if (Platform.isAndroid) {
        return AlertDialog(
          title: const Text(
            'Comprueba tu correo',
            textAlign: TextAlign.center,
          ),
          content:
              const Text('Te hemos enviado un correo para verificar tu cuenta'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      } else {
        return CupertinoAlertDialog(
          title: const Text(
            'Comprueba tu correo',
            textAlign: TextAlign.center,
          ),
          content:
              const Text('Te hemos enviado un correo para verificar tu cuenta'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      }
    },
  );
}
