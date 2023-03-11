import 'package:zonzacar/widgets/widgets.dart';
import 'package:flutter/material.dart';

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

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            textController: passCtrl,
            isPassword: true,
          ),
          BotonVerde(
            text: 'Acceder', 
            onPressed: () {
              print(emailCtrl.text);
              print(passCtrl.text);
              Navigator.pushReplacementNamed(context, 'home');
            },
          )
        ],
      ),
    );
  }
}

