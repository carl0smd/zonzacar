
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zonzacar/helpers/helper_function.dart';
import 'package:zonzacar/providers/database_provider.dart';

class AuthProvider {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final helper = HelperFunctions();

  //login
  Future loginUser(String email, String password) async {

    try {
      User? user = (await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password,)).user;

      if (user != null) {
        return true;
      }

    } on FirebaseAuthException catch (errors) {
      return errors.message;
    }
  }

  //register
  Future registerUser(String nombreCompleto, String email, String password) async {

    try {
      User? user = (await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password,)).user;

      if (user != null) {
        await DatabaseProvider(uid: user.uid).savingUserData(nombreCompleto, email);
        return true;
      }

    } on FirebaseAuthException catch (errors) {
      return errors.message;
    }
  }

  //log out
  Future logOut() async {
    try {
      await helper.saveUserLoggedInStatus(false);
      await firebaseAuth.signOut();
    } catch (errors) {
      return null;
    }
  }

  //send email verification
  Future sendEmailVerification() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (errors) {
      return errors.message;
    }
  }

  //check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = firebaseAuth.currentUser;
    await user!.reload();
    if (user.emailVerified) {
      return true;
    }
    return false;
  }
}