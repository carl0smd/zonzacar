

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HelperFunctions {

  final _storage = const FlutterSecureStorage();

  //keys
  final String userLoggedInKey = "LOGGEDINKEY";

  //Guardar los datos en SS
  Future saveUserLoggedInStatus(isUserLoggedIn) async {
    final writeStatus = await _storage.write(key: userLoggedInKey, value: isUserLoggedIn.toString());
    return writeStatus;
  }

  //Obtener los datos de SS
  Future getUserLoggedInStatus() async {
    final readStatus = await _storage.read(key: userLoggedInKey);
    return readStatus;
  }
 
}