import 'package:zonzacar/screens/screens.dart';
import 'package:flutter/material.dart';

//APP MAIN ROUTES

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'login': (_) => const LoginScreen(),
  'register': (_) => const RegisterScreen(),
  'home': (_) => const MenuScreen(),
};
