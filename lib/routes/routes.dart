
import 'package:zonzacar/screens/screens.dart';
import 'package:flutter/material.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {

  // 'usuarios': ( _ ) => const UsuariosScreen(),
  // 'chat'    : ( _ ) => const ChatScreen(),
  'login'   : ( _ ) => const LoginScreen(),
  'register': ( _ ) => const RegisterScreen(),
  'loading' : ( _ ) => const LoadingScreen(),
  'home'    : ( _ ) => const MenuScreen(),

};