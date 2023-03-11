
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseProvider {

  final String? uid;
  DatabaseProvider({this.uid});

  //collection reference
  final CollectionReference usuarioCollection = 
    FirebaseFirestore.instance.collection('usuarios');

  final CollectionReference publicacionesCollection = 
    FirebaseFirestore.instance.collection('publicaciones');

  final CollectionReference reservasCollection = 
    FirebaseFirestore.instance.collection('reservas');

  //updating the userdata
  Future savingUserData(String nombreCompleto, String email) async {
    return await usuarioCollection.doc(uid).set({
      'nombreCompleto': nombreCompleto,
      'email': email,
      'publicaciones': [],
      'reservas': [],
      'fotoPerfil': '',
      'uid': uid,
    });
  }

  //getting the userdata
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot = await usuarioCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }
}