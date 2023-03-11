
import 'package:zonzacar/widgets/widgets.dart';
import 'package:flutter/material.dart';

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
              children: const [
                Logo(titulo: 'Registro'),
                _Form(),
                Labels(ruta: 'login', text: '¿Ya tienes cuenta?', gestureText: 'Accede desde aquí!'),
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

  final nombreCtrl = TextEditingController();
  final emailCtrl  = TextEditingController();
  final passCtrl   = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.perm_identity,
            placeholder: 'Nombre',
            textController: nombreCtrl,
          ),
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
          BotonVerde (
            text: 'Crear cuenta', 
            onPressed: () {
              print(emailCtrl.text);
              print(passCtrl.text);
            },
          )
        ],
      ),
    );
  }
}

