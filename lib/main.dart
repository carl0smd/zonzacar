import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zonzacar/routes/routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('es', 'ES')
      ],
      title: 'zonzaCar',
      initialRoute: 'login',
      routes: appRoutes,
      theme: ThemeData(
        primarySwatch: Colors.green,
      )
    );
  }
}