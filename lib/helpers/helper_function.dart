import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HelperFunctions {
  final _storage = const FlutterSecureStorage();

  //keys
  final String userLoggedInKey = "LOGGEDINKEY";
  final String userEmailKey = "USEREMAILKEY";
  final String userNameKey = "USERNAMEKEY";

  //Save data to SecureStorage

  Future saveUserLoggedInStatus(isUserLoggedIn) async {
    final writeStatus = await _storage.write(
      key: userLoggedInKey,
      value: isUserLoggedIn.toString(),
    );
    return writeStatus;
  }

  Future saveUserEmail(email) async {
    final writeEmail = await _storage.write(key: userEmailKey, value: email);
    return writeEmail;
  }

  Future saveUserName(name) async {
    final writeName = await _storage.write(key: userNameKey, value: name);
    return writeName;
  }

  //Get data from SecureStorage

  Future getUserLoggedInStatus() async {
    final readStatus = await _storage.read(key: userLoggedInKey);
    return readStatus;
  }

  Future getUserEmail() async {
    final readEmail = await _storage.read(key: userEmailKey);
    return readEmail;
  }

  Future getUserName() async {
    final readName = await _storage.read(key: userNameKey);
    return readName;
  }
}
