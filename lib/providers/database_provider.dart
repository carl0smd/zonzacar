import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatabaseProvider {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  final String? uid;
  DatabaseProvider({this.uid});

  static final estadoPublicacion = {
    'disponible': 'Disponible',
    'llena': 'Llena',
    'encurso': 'En curso',
    'finalizada': 'Finalizada',
  };

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
    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'nombreCompleto': nombreCompleto,
    });
  }

  //buscar al usuario en la base de datos por email
  Future gettingUserDataByEmail(String email) async {
    QuerySnapshot snapshot =
        await usuarioCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  //get usuario actual
  Future getCurrentUser() async {
    QuerySnapshot snapshot = await usuarioCollection
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return snapshot;
  }

  //get usuario por uid
  Future getUserByUid(String uid) async {
    QuerySnapshot snapshot =
        await usuarioCollection.where('uid', isEqualTo: uid).get();
    return snapshot.docs;
  }

  //get usuarios que compartan coche en una publicacion
  Future getUsersSharingCar(String uidPublication) async {
    QuerySnapshot snapshotReservas = await reservasCollection
        .where('publicacion', isEqualTo: uidPublication)
        .get();
    List<String> usuarios = [];
    for (var reserva in snapshotReservas.docs) {
      usuarios.add(reserva['pasajero']);
    }
    QuerySnapshot snapshotUsuarios =
        await usuarioCollection.where('uid', whereIn: usuarios).get();
    return snapshotUsuarios.docs;
  }

  //guardar imagen de perfil
  Future storeProfileImage(String userImage) async {
    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'imagenPerfil': userImage,
    });
  }

  //eliminar usuario de la base de datos
  Future deleteUser() async {
    await usuarioCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
  }

  //guardar vehiculos
  Future saveVehicle(
      String matricula, String marca, String modelo, String color) async {
    final id = vehiculosCollection.doc().id;
    await vehiculosCollection.doc(id).set({
      'matricula': matricula,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'conductor': FirebaseAuth.instance.currentUser!.uid,
      'uid': id,
    });

    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'vehiculos': FieldValue.arrayUnion([id]),
    });
  }

  //get vehiculo por uid
  Future getVehicleByUid(String uid) async {
    QuerySnapshot snapshot =
        await vehiculosCollection.where('uid', isEqualTo: uid).get();
    return snapshot.docs;
  }

  //get vehiculos de usuario
  Future getVehicles() async {
    QuerySnapshot snapshot = await vehiculosCollection
        .where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return snapshot.docs;
  }

  //eliminar vehiculo
  Future deleteVehicle(String uid) async {
    //get publicaciones del vehiculo
    QuerySnapshot snapshotPublicaciones =
        await publicacionesCollection.where('vehiculo', isEqualTo: uid).get();

    if (snapshotPublicaciones.docs.isNotEmpty) {
      return false;
    } else {
      await vehiculosCollection.doc(uid).delete();
      await usuarioCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'vehiculos': FieldValue.arrayRemove([uid]),
      });
      return true;
    }
  }

  //guardar publicacion
  Future savePublication(
    int fecha,
    String duracionViaje,
    String distancia,
    String hora,
    String origen,
    String destino,
    String coordenadasOrigen,
    String coordenadasDestino,
    int asientos,
    double precio,
    String uidVehiculo,
  ) async {
    final id = vehiculosCollection.doc().id;
    await publicacionesCollection.doc(id).set({
      'pasajeros': [],
      'fecha': fecha,
      'horaSalida': hora,
      'duracionViaje': duracionViaje,
      'distancia': distancia,
      'origen': origen,
      'destino': destino,
      'coordenadasOrigen': coordenadasOrigen,
      'coordenadasDestino': coordenadasDestino,
      'asientosDisponibles': asientos,
      'precio': precio,
      'vehiculo': uidVehiculo,
      'conductor': FirebaseAuth.instance.currentUser!.uid,
      'estado': estadoPublicacion['disponible'],
      'uid': id,
    });

    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'publicaciones': FieldValue.arrayUnion([id]),
    });
  }

  //get publicaciones
  Future getPublications(String id) async {
    QuerySnapshot snapshot =
        await publicacionesCollection.where('uid', isEqualTo: id).get();
    return snapshot.docs;
  }

  //get publicaciones hacia el Zonzamas
  Future getPublicationsToZonzamas([dynamic fecha]) async {
    if (fecha != null) {
      QuerySnapshot snapshot = await publicacionesCollection
          .where('fecha', isGreaterThanOrEqualTo: fecha)
          .where('fecha', isLessThanOrEqualTo: fecha + 86399000)
          .where('destino', isEqualTo: 'CIFP Zonzamas')
          .where('estado', isEqualTo: estadoPublicacion['disponible'])
          .orderBy('fecha')
          .orderBy('horaSalida')
          .orderBy('origen')
          .get();
      return snapshot.docs;
    } else {
      DateTime today = DateTime.now();
      final dateToSearch = today.millisecondsSinceEpoch;
      QuerySnapshot snapshot = await publicacionesCollection
          .where('fecha', isGreaterThanOrEqualTo: dateToSearch)
          .where('destino', isEqualTo: 'CIFP Zonzamas')
          .where('estado', isEqualTo: estadoPublicacion['disponible'])
          .orderBy('fecha')
          .orderBy('horaSalida')
          .orderBy('origen')
          .get();
      return snapshot.docs;
    }
  }

  //get publicaciones desde el Zonzamas
  Future getPublicationsFromZonzamas([dynamic fecha]) async {
    if (fecha != null) {
      QuerySnapshot snapshot = await publicacionesCollection
          .where('fecha', isGreaterThanOrEqualTo: fecha)
          .where('fecha', isLessThanOrEqualTo: fecha + 86399000)
          .where('origen', isEqualTo: 'CIFP Zonzamas')
          .where('estado', isEqualTo: estadoPublicacion['disponible'])
          .orderBy('fecha')
          .orderBy('horaSalida')
          .orderBy('destino')
          .get();
      return snapshot.docs;
    } else {
      DateTime today = DateTime.now();
      final dateToSearch = today.millisecondsSinceEpoch;
      QuerySnapshot snapshot = await publicacionesCollection
          .where('fecha', isGreaterThanOrEqualTo: dateToSearch)
          .where('origen', isEqualTo: 'CIFP Zonzamas')
          .where('estado', isEqualTo: estadoPublicacion['disponible'])
          .orderBy('fecha')
          .orderBy('horaSalida')
          .orderBy('destino')
          .get();
      return snapshot.docs;
    }
  }

  //get publicaciones dónde el usuario es conductor
  Future getPublicationsByDriver() async {
    QuerySnapshot snapshot = await publicacionesCollection
        .where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return snapshot.docs;
  }

  //get publicaciones dónde el usuario es pasajero
  Future getPublicationsByPassenger() async {
    QuerySnapshot snapshot = await publicacionesCollection
        .where(
          'pasajeros',
          arrayContains: FirebaseAuth.instance.currentUser!.uid,
        )
        .get();
    return snapshot.docs;
  }

  //delete publication
  Future deletePublication(String uid) async {
    QuerySnapshot snapshotReservas =
        await reservasCollection.where('publicacion', isEqualTo: uid).get();

    if (snapshotReservas.docs.isNotEmpty) {
      for (var reserva in snapshotReservas.docs) {
        await usuarioCollection.doc(reserva['pasajero']).update({
          'reservas': FieldValue.arrayRemove([reserva['uid']]),
        });
      }
    }

    await reservasCollection.where('publicacion', isEqualTo: uid).get().then(
      (snapshot) {
        for (var reserva in snapshot.docs) {
          reservasCollection.doc(reserva['uid']).delete();
        }
      },
    );

    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'publicaciones': FieldValue.arrayRemove([uid]),
    });

    await publicacionesCollection.doc(uid).delete();
  }

  //get usuarios a partir de una lista de ids de pasaajeros de una publicacion
  Future getPassengers(String uid) async {
    QuerySnapshot snapshotReservas =
        await reservasCollection.where('publicacion', isEqualTo: uid).get();

    List<String> passengers = [];

    if (snapshotReservas.docs.isNotEmpty) {
      for (var reserva in snapshotReservas.docs) {
        passengers.add(reserva['pasajero']);
      }
    }

    QuerySnapshot snapshotUsuarios =
        await usuarioCollection.where('uid', whereIn: passengers).get();

    return snapshotUsuarios.docs;
  }

  //comprobar que el viaje no está lleno
  Future<bool> checkIfFull(String uid) async {
    DocumentSnapshot snapshot = await publicacionesCollection.doc(uid).get();
    final asientosDisponibles = snapshot['asientosDisponibles'];
    final pasajeros = snapshot['pasajeros'];
    if (asientosDisponibles > pasajeros.length) {
      return false;
    } else {
      return true;
    }
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
    });

    if (await checkIfFull(uidPublicacion)) {
      await publicacionesCollection.doc(uidPublicacion).update({
        'estado': estadoPublicacion['llena'],
      });
    }
  }

  //eliminar reserva
  Future deleteReservation(String uidPublicacion) async {
    QuerySnapshot snapshot = await reservasCollection
        .where('publicacion', isEqualTo: uidPublicacion)
        .where('pasajero', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    final uid = snapshot.docs[0]['uid'];

    await reservasCollection.doc(uid).delete();

    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'reservas': FieldValue.arrayRemove([uid]),
    });

    await publicacionesCollection.doc(uidPublicacion).update({
      'pasajeros':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      'estado': estadoPublicacion['disponible'],
    });
  }
}
