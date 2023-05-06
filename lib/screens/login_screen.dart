import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/screens/screens.dart';
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
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Logo(titulo: 'Acceso'),
                _Form(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//Formulario de login
class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  final formKey = GlobalKey<FormState>();
  final forgetPasswordKey = GlobalKey<FormFieldState>();
  final helper = HelperFunctions();
  final forgetPasswordController = TextEditingController();

  bool _isLoading = false;
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
          : Form(
              key: formKey,
              child: Column(
                children: [
                  Column(
                    children: [
                      //Campo de correo
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
                          ).hasMatch(value!)
                              ? null
                              : 'Introduce un correo válido';
                        },
                      ),
                      //Campo de contraseña
                      CustomInput(
                        icon: Icons.lock_outline,
                        placeholder: 'Contraseña',
                        isPassword: true,
                        onChanged: (value) {
                          password = value;
                          setState(() {});
                        },
                        validator: (value) {
                          //la contraseña tener al menos  6 caracteres sin espacios
                          return RegExp(r"^\S{6,}$").hasMatch(value!)
                              ? null
                              : 'La contraseña debe tener al menos 6 caracteres sin espacios';
                        },
                      ),
                      //Botón de acceso
                      BotonVerde(
                        text: 'Acceder',
                        onPressed: () {
                          login(email, password);
                          // Navigator.pushReplacementNamed(context, 'home');
                        },
                      ),
                      //He olvidado mi contraseña
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Cambiar contraseña'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        '¿Introduce tú correo electrónico?',
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      TextFormField(
                                        controller: forgetPasswordController,
                                        key: forgetPasswordKey,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                            labelText: 'Correo electrónico',
                                            border: OutlineInputBorder()),
                                        validator: (value) {
                                          return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                          ).hasMatch(value!)
                                              ? null
                                              : 'Introduce un correo válido';
                                        },
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      BotonVerde(
                                        text: 'Enviar',
                                        onPressed: () async {
                                          if (forgetPasswordKey.currentState!
                                              .validate()) {
                                            await authProvider
                                                .resetPassword(
                                              forgetPasswordController.text,
                                            )
                                                .then((value) {
                                              if (value == true) {
                                                Navigator.pop(context);
                                                showSnackbar(
                                                  'Se ha enviado un correo para cambiar la contraseña',
                                                  context,
                                                );
                                              } else {
                                                showSnackbar(
                                                  'No se ha podido enviar el correo, comprueba que el correo sea correcto',
                                                  context,
                                                  duration: const Duration(
                                                    seconds: 5,
                                                  ),
                                                );
                                              }
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  //Botón de registro
                  const Labels(
                    ruta: 'register',
                    text: '¿No tienes cuenta?',
                    gestureText: 'Crea una ahora!',
                  ),
                  // const SizedBox(height: 40,),
                  // Text('Términos y condiciones de uso', style: TextStyle(fontWeight: FontWeight.w200),),
                ],
              ),
            ),
    );
  }

  //Función para iniciar sesión
  login(email, password) async {
    if (formKey.currentState!.validate()) {
      setState(() {});
      _isLoading = true;

      await authProvider.loginUser(email, password).then((value) async {
        if (value == true) {
          if (await authProvider.isEmailVerified()) {
            QuerySnapshot snapshot = await DatabaseProvider(
              uid: FirebaseAuth.instance.currentUser!.uid,
            ).gettingUserDataByEmail(email);
            await helper.saveUserLoggedInStatus(true);
            await helper.saveUserEmail(email);
            await helper.saveUserName(snapshot.docs[0].get('nombreCompleto'));
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenuScreen()),
              );
            }
          } else {
            if (mounted) showSnackbar('Por favor verifique su correo', context);
            setState(() {});
            _isLoading = false;
          }
        } else {
          showSnackbar(
            'Esta cuenta no existe o ha introducido algún dato erroneo',
            context,
          );
          setState(() {});
          _isLoading = false;
        }
      });
    }
  }
}
