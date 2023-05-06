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
        email: email,
        password: password,
      ))
          .user;

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (errors) {
      return errors.message;
    }
  }

  //register
  Future registerUser(
      String nombreCompleto, String email, String password) async {
    try {
      User? user = (await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;

      if (user != null) {
        await DatabaseProvider(uid: user.uid)
            .savingUserDataOnRegister(nombreCompleto, email);
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

  //reset password
  Future resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (errors) {
      return errors.message;
    }
  }

  //ask for reauthentication
  Future reauthenticate(String password) async {
    try {
      User? user = firebaseAuth.currentUser;
      AuthCredential credential =
          EmailAuthProvider.credential(email: user!.email!, password: password);
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (errors) {
      switch (errors.code) {
        case "wrong-password":
          return "wrong-password";

        case "too-many-requests":
          return "too-many-requests";

        default:
          return false;
      }
    }
  }
}
