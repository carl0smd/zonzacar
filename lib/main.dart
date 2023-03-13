import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zonzacar/helpers/helper_function.dart';
import 'package:zonzacar/routes/routes.dart';
import 'package:zonzacar/shared/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: Constants.apiKey, 
      appId: Constants.appId, 
      messagingSenderId: Constants.messagingSenderId, 
      projectId: Constants.projectId
    ));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // bool _isSignedIn = false;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // getUserLoggedInStatus();
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  // getUserLoggedInStatus() async {
    // await HelperFunctions.getUserLoggedInStatus().then((value) {
    //   if(value!=null) {
    //     _isSignedIn = value;
    //     setState(() {});
    //   }
    // });
  // }

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
      initialRoute: user != null ? 'home' : 'login',
      routes: appRoutes,
      theme: ThemeData(
        primarySwatch: Colors.green,
      )
    );
  }
}