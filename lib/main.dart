import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zonzacar/helpers/helper_function.dart';
import 'package:zonzacar/routes/routes.dart';
import 'package:zonzacar/shared/constants.dart';

import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: FirebaseConstants.apiKey, 
      appId: FirebaseConstants.appId, 
      messagingSenderId: FirebaseConstants.messagingSenderId, 
      projectId: FirebaseConstants.projectId
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
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoggedInStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkLoggedInStatus() async {
    final helper = HelperFunctions();
    return helper.getUserLoggedInStatus().then((value) {
      if (value == 'true') {
        setState(() {
          _isLoggedIn = true;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES')
      ],
      title: 'zonzaCar',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        initialData: FirebaseAuth.instance.currentUser,
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData && _isLoggedIn) {
            return const MenuScreen();
          } else {
            return const LoginScreen();
          } 
        },
      ),
      routes: appRoutes,
      theme: ThemeData(
        primarySwatch: Colors.green,
      )
    );
  }
}