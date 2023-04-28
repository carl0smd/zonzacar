
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatabaseProvider {

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

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

  //get usuario por uid
  Future getUserByUid(String uid) async {
    QuerySnapshot snapshot = await usuarioCollection.where('uid', isEqualTo: uid).get();
    return snapshot.docs;
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
  Future saveVehicle(String matricula, String marca, String modelo, String color) async {
    final id = vehiculosCollection.doc().id;
    await vehiculosCollection.doc(id).set({
      'matricula': matricula,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'conductor': FirebaseAuth.instance.currentUser!.uid,
      'uid' : id,
    });

    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'vehiculos': FieldValue.arrayUnion([id]),
    });
  }

  //get vehiculo por uid
  Future getVehicleByUid(String uid) async {
    QuerySnapshot snapshot = await vehiculosCollection.where('uid', isEqualTo: uid).get();
    return snapshot.docs;
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

  //guardar publicacion
  Future savePublication(int fecha, String hora, String origen, String destino, String coordenadasOrigen, String coordenadasDestino, int asientos, double precio, String uidVehiculo) async {
    final id = vehiculosCollection.doc().id;
    await publicacionesCollection.doc(id).set({
      'pasajeros': [],
      'fecha': fecha,
      'horaSalida': hora,
      'origen': origen,
      'destino': destino,
      'coordenadasOrigen': coordenadasOrigen,
      'coordenadasDestino': coordenadasDestino,
      'asientosDisponibles': asientos,
      'precio': precio,
      'vehiculo': uidVehiculo,
      'conductor': FirebaseAuth.instance.currentUser!.uid,
      'uid': id,
    });

    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'publicaciones': FieldValue.arrayUnion([id]),
    });
  }

  //add pasajero a la publicacion
  Future addPassengerToPublication(String uidPublicacion, String uidPasajero) async {
    await publicacionesCollection.doc(uidPublicacion).update({
      'pasajeros': FieldValue.arrayUnion([uidPasajero]),
    });
  }

  //get publicaciones
  Future getPublications(String id) async {
    QuerySnapshot snapshot = await publicacionesCollection.where('uid', isEqualTo: id).get();
    return snapshot.docs;
  }

  //get publicaciones hacia el Zonzamas
  Future getPublicationsToZonzamas([dynamic fecha]) async {
    if (fecha != null) {
      QuerySnapshot snapshot = await publicacionesCollection.where('fecha', isEqualTo: fecha).where('destino', isEqualTo: 'CIFP Zonzamas').orderBy('horaSalida').orderBy('origen').get();
      return snapshot.docs;
    } else {
      DateTime today = DateTime.now();
      final dateToSearch = today.millisecondsSinceEpoch;
      QuerySnapshot snapshot = await publicacionesCollection.where('fecha', isGreaterThanOrEqualTo: dateToSearch).where('destino', isEqualTo: 'CIFP Zonzamas').orderBy('fecha').orderBy('horaSalida').orderBy('origen').get();
      return snapshot.docs;
    }
  }

  //get publicaciones desde el Zonzamas
  Future getPublicationsFromZonzamas([dynamic fecha]) async {
    if (fecha != null) {
      
      QuerySnapshot snapshot = await publicacionesCollection.where('fecha', isEqualTo: fecha).where('origen', isEqualTo: 'CIFP Zonzamas').orderBy('horaSalida').orderBy('destino').get();
      return snapshot.docs;
    } else {
      DateTime today = DateTime.now();
      final dateToSearch = today.millisecondsSinceEpoch;
      QuerySnapshot snapshot = await publicacionesCollection.where('fecha', isGreaterThanOrEqualTo: dateToSearch).where('origen', isEqualTo: 'CIFP Zonzamas').orderBy('fecha').orderBy('horaSalida').orderBy('destino').get();
      return snapshot.docs;
    }
  }

  //get publicaciones de usuario
  Future getPublicationsByUser() async {
    QuerySnapshot snapshot = await publicacionesCollection.where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    return snapshot.docs;
  }
  
  //guardar reserva
  Future saveReservation(String uidPublicacion, String uidPasajero) async {
    final id = reservasCollection.doc().id;
    await reservasCollection.doc(id).set({
      'publicacion': uidPublicacion,
      'pasajero': FirebaseAuth.instance.currentUser!.uid,
      'uid': id,
    });

    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'reservas': FieldValue.arrayUnion([id]),
    });

    await publicacionesCollection.doc(uidPublicacion).update({
      'pasajeros': FieldValue.arrayUnion([uidPasajero]),
      'plazasDisponibles': FieldValue.increment(-1),
    });
  }

  //get reservas de usuario
  Future getReservationsByUser() async {
    QuerySnapshot snapshot = await reservasCollection.where('pasajero', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    return snapshot.docs;
  }

  
}