
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
    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid)
    .update({
      'nombreCompleto': nombreCompleto,
    });
  }

  //buscar al usuario en la base de datos por email
  Future gettingUserDataByEmail(String email) async {
    QuerySnapshot snapshot = await usuarioCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  //get usuario actual
  Future getCurrentUser() async {
    QuerySnapshot snapshot = await usuarioCollection.where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    return snapshot;
  }

  //guardar imagen de perfil
  Future storeProfileImage(String userImage) async {
    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid)
    .update({
      'imagenPerfil': userImage,
    });
  }

  //eliminar usuario de la base de datos
  Future deleteUser() async {
    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).delete();
  }

  //guardar vehiculos
  Future saveVehicle(String matricula, String marca, String modelo, String plazas, String color) async {
    final id = vehiculosCollection.doc().id;
    await vehiculosCollection.doc(id).set({
      'matricula': matricula,
      'marca': marca,
      'modelo': modelo,
      'plazas' : plazas,
      'color': color,
      'conductor': FirebaseAuth.instance.currentUser!.uid,
      'uid' : id,
    });

    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'vehiculos': FieldValue.arrayUnion([id]),
    });
  }

  //get vehiculos de usuario
  Future getVehicles() async {
    QuerySnapshot snapshot = await vehiculosCollection.where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    return snapshot.docs;
  }

  //eliminar vehiculo
  Future deleteVehicle(String uid) async {
    await vehiculosCollection.doc(uid).delete();
    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'vehiculos': FieldValue.arrayRemove([uid]),
    });
  }


  
}