
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseProvider {

  final String? uid;
  DatabaseProvider({this.uid});

  //referencias a las colecciones de la base de datos
  final CollectionReference usuarioCollection = 
    FirebaseFirestore.instance.collection('usuarios');

  final CollectionReference publicacionesCollection = 
    FirebaseFirestore.instance.collection('publicaciones');

  final CollectionReference reservasCollection = 
    FirebaseFirestore.instance.collection('reservas');

  final CollectionReference vehiculosCollection = 
    FirebaseFirestore.instance.collection('vehiculos');

  //guardar al usuario en la base de datos cuando se registra
  Future savingUserDataOnRegister(String nombreCompleto, String email) async {
    return await usuarioCollection.doc(uid).set({
      'nombreCompleto': nombreCompleto,
      'email': email,
      'publicaciones': [],
      'reservas': [],
      'vehiculos': [],
      'imagenPerfil': '',
      'uid': uid,
    });
  }

  //actualizar nombre de usuario
  Future updateUserName(String nombreCompleto) async {
    usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid)
    .set({
      'nombreCompleto': nombreCompleto,
    }, SetOptions(merge: true));
  }

  //buscar al usuario en la base de datos por email
  Future gettingUserDataByEmail(String email) async {
    QuerySnapshot snapshot = await usuarioCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  //guardar imagen de perfil
  Future storeProfileImage(String userImage) async {
    usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid)
    .set({
      'imagenPerfil': userImage,
    }, SetOptions(merge: true));
  }

  //guardar vehiculos
  Future storeVehicle(String matricula, String marca, String modelo, String color) async {
    vehiculosCollection.doc(matricula).set({
      'matricula': matricula,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'conductor': FirebaseAuth.instance.currentUser!.uid,
    });
    usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid)
    .set({
      'vehiculos': FieldValue.arrayUnion([matricula]),
    });
  }
}