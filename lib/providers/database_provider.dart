import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:zonzacar/helpers/helper_function.dart';
import 'package:zonzacar/providers/notifications_provider.dart';

class DatabaseProvider {
  final String? uid;
  DatabaseProvider({this.uid});

  HelperFunctions helperFunctions = HelperFunctions();

  static final estadoPublicacion = {
    'disponible': 'Disponible',
    'llena': 'Llena',
    'encurso': 'En curso',
    'finalizada': 'Finalizada',
    'expulsado': 'Expulsado',
  };

  //References to the collections
  final CollectionReference usuarioCollection =
      FirebaseFirestore.instance.collection('usuarios');

  final CollectionReference publicacionesCollection =
      FirebaseFirestore.instance.collection('publicaciones');

  final CollectionReference reservasCollection =
      FirebaseFirestore.instance.collection('reservas');

  final CollectionReference vehiculosCollection =
      FirebaseFirestore.instance.collection('vehiculos');

  final CollectionReference chatsCollection =
      FirebaseFirestore.instance.collection('chats');

  //Save user data on register
  Future savingUserDataOnRegister(String nombreCompleto, String email) async {
    return await usuarioCollection.doc(uid).set({
      'nombreCompleto': nombreCompleto,
      'email': email,
      'publicaciones': [],
      'reservas': [],
      'vehiculos': [],
      'mediaValoraciones': 0,
      'unaEstrella': 0,
      'dosEstrellas': 0,
      'tresEstrellas': 0,
      'cuatroEstrellas': 0,
      'cincoEstrellas': 0,
      'imagenPerfil': '',
      'uid': uid,
      'pushToken': await FirebaseMessaging.instance.getToken(),
    });
  }

  //update user push token
  Future updateUserPushToken() async {
    if (helperFunctions.userLoggedInKey == 'true') {
      await usuarioCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'pushToken': await FirebaseMessaging.instance.getToken(),
      });
    }
  }

  //update user name
  Future updateUserName(String nombreCompleto) async {
    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'nombreCompleto': nombreCompleto,
    });
  }

  //search user by email
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

  //get user by uid
  Future getUserByUid(String uid) async {
    QuerySnapshot snapshot =
        await usuarioCollection.where('uid', isEqualTo: uid).get();
    return snapshot.docs;
  }

  //get all users by uid
  Future getAllUsersByUid(List<String> ids, bool isDriver) async {
    List<DocumentSnapshot> users = [];
    List lastMessageDates = [];
    for (var id in ids) {
      DocumentSnapshot snapshot = await usuarioCollection.doc(id).get();
      users.add(snapshot);
    }

    if (isDriver) {
      //search for chats where i'm pasajero and user is conductor and then order users by fechaUltimoMensaje
      for (var user in users) {
        QuerySnapshot snapshot = await chatsCollection
            .where(
              'pasajero',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
            .where('conductor', isEqualTo: user['uid'])
            .get();
        if (snapshot.docs.isNotEmpty) {
          lastMessageDates.add(snapshot.docs[0]['fechaUltimoMensaje']);
        } else {
          lastMessageDates.add(0);
        }
      }
    } else {
      //search for chats where i'm conductor and user is pasajero and then order users bt fechaUltimoMensaje
      for (var user in users) {
        QuerySnapshot snapshot = await chatsCollection
            .where('conductor',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where('pasajero', isEqualTo: user['uid'])
            .get();
        if (snapshot.docs.isNotEmpty) {
          lastMessageDates.add(snapshot.docs[0]['fechaUltimoMensaje']);
        } else {
          lastMessageDates.add(0);
        }
      }
    }

    //order users list by lastMessageDate
    for (var i = 0; i < users.length; i++) {
      for (var j = 0; j < users.length - 1; j++) {
        if (lastMessageDates[j] < lastMessageDates[j + 1]) {
          var aux = lastMessageDates[j];
          lastMessageDates[j] = lastMessageDates[j + 1];
          lastMessageDates[j + 1] = aux;

          var aux2 = users[j];
          users[j] = users[j + 1];
          users[j + 1] = aux2;
        }
      }
    }

    return users;
  }

  //get users that share car in the same publication
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

  //save user profile image url on database
  Future storeProfileImage(String userImage) async {
    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'imagenPerfil': userImage,
    });
  }

  //delete user
  Future deleteUser(bool correctCredentials) async {
    if (!correctCredentials) {
      return;
    }

    //delete chats where user is pasajero || conductor
    QuerySnapshot snapshotChats = await chatsCollection
        .where('pasajero', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    //delete subcollection mensajes

    for (var chat in snapshotChats.docs) {
      await chatsCollection
          .doc(chat.id)
          .collection('mensajes')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
    }

    for (var chat in snapshotChats.docs) {
      await chatsCollection.doc(chat.id).delete();
    }

    QuerySnapshot snapshotChats2 = await chatsCollection
        .where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    for (var chat in snapshotChats2.docs) {
      await chatsCollection.doc(chat.id).delete();
    }

    //delete reservas where user is pasajero

    QuerySnapshot snapshotReservas = await reservasCollection
        .where('pasajero', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    for (var reserva in snapshotReservas.docs) {
      await reservasCollection.doc(reserva.id).delete();
      await usuarioCollection.doc(reserva['pasajero']).update({
        'reservas': FieldValue.arrayRemove([reserva.id]),
      });
    }

    //delete reservas where publicacion is equal to any of the user's publicaciones

    QuerySnapshot snapshotPublicaciones = await publicacionesCollection
        .where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    for (var publicacion in snapshotPublicaciones.docs) {
      QuerySnapshot snapshotReservas = await reservasCollection
          .where('publicacion', isEqualTo: publicacion.id)
          .get();

      for (var reserva in snapshotReservas.docs) {
        await reservasCollection.doc(reserva.id).delete();
      }
    }

    for (var publicacion in snapshotPublicaciones.docs) {
      await publicacionesCollection.doc(publicacion.id).delete();
    }

    //delete user from publicaciones where user is pasajero

    QuerySnapshot snapshotPublicaciones2 = await publicacionesCollection
        .where(
          'pasajeros',
          arrayContains: FirebaseAuth.instance.currentUser!.uid,
        )
        .get();

    for (var publicacion in snapshotPublicaciones2.docs) {
      await publicacionesCollection.doc(publicacion.id).update({
        'pasajeros': FieldValue.arrayRemove(
          [FirebaseAuth.instance.currentUser!.uid],
        ),
      });
    }

    //delete vechicle

    QuerySnapshot snapshotVehiculos = await vehiculosCollection
        .where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    for (var vehiculo in snapshotVehiculos.docs) {
      await vehiculosCollection.doc(vehiculo.id).delete();
    }

    //delete imagePerfil from firebase storage

    String imagePerfil = await usuarioCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) => value['imagenPerfil']);

    if (imagePerfil != '') {
      await FirebaseStorage.instance.refFromURL(imagePerfil).delete();
    }

    // delete user from firebase auth and db

    await usuarioCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();

    await FirebaseAuth.instance.currentUser!.delete();

    helperFunctions.saveUserLoggedInStatus(false);
  }

  //create vehicle
  Future saveVehicle(
    String matricula,
    String marca,
    String modelo,
    String color,
  ) async {
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

  //get vehicle by uid
  Future getVehicleByUid(String uid) async {
    QuerySnapshot snapshot =
        await vehiculosCollection.where('uid', isEqualTo: uid).get();
    return snapshot.docs;
  }

  //get vehicles of user
  Future getVehicles() async {
    QuerySnapshot snapshot = await vehiculosCollection
        .where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return snapshot.docs;
  }

  //delete vehicle
  Future deleteVehicle(String uid) async {
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

  //save publication
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
      'valoraciones': [],
      'uid': id,
    });

    await usuarioCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'publicaciones': FieldValue.arrayUnion([id]),
    });
  }

  //update publication (estado)
  Future updatePublicationState(String uid, String estado) async {
    await publicacionesCollection.doc(uid).update({
      'estado': estado,
    });
  }

  //delete passenger from publication
  Future deletePassengerFromPublication(
    String uidPublication,
    String uidPassenger,
  ) async {
    await publicacionesCollection.doc(uidPublication).update({
      'pasajeros': FieldValue.arrayRemove(
        [uidPassenger],
      ),
    });
  }

  //check if publication starts trip today without the hour
  Future checkIfPublicationStartsTripToday(String uidPublication) async {
    QuerySnapshot snapshot = await publicacionesCollection
        .where('uid', isEqualTo: uidPublication)
        .get();
    final publication = snapshot.docs[0];
    final publicationDate = DateTime.fromMillisecondsSinceEpoch(
      publication['fecha'],
    );
    final today = DateTime.now();
    if (publicationDate.day == today.day &&
        publicationDate.month == today.month &&
        publicationDate.year == today.year) {
      return true;
    } else {
      return false;
    }
  }

  //get publications by uid
  Future getPublications(String id) async {
    QuerySnapshot snapshot =
        await publicacionesCollection.where('uid', isEqualTo: id).get();
    return snapshot.docs;
  }

  //get publications to zonzamas
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

  //get publications from zonzamas
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

  //get publications where I am passenger
  Future getPublicationsByDriver() async {
    QuerySnapshot snapshot = await publicacionesCollection
        .where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('fecha')
        .get();
    return snapshot.docs;
  }

  //get passengers from my publications
  Future<List<String>> getAllMyPassengers() async {
    QuerySnapshot snapshot = await publicacionesCollection
        .where('conductor', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    List<String> pasajeros = [];

    for (var publicacion in snapshot.docs) {
      for (var pasajero in publicacion['pasajeros']) {
        if (!pasajeros.contains(pasajero)) {
          pasajeros.add(pasajero);
        }
      }
    }

    return pasajeros;
  }

  //get all my drivers
  Future<List<String>> getAllMyDrivers() async {
    QuerySnapshot snapshot = await publicacionesCollection
        .where(
          'pasajeros',
          arrayContains: FirebaseAuth.instance.currentUser!.uid,
        )
        .get();

    List<String> conductores = [];

    for (var publicacion in snapshot.docs) {
      if (!conductores.contains(publicacion['conductor'])) {
        conductores.add(publicacion['conductor']);
      }
    }

    return conductores;
  }

  //get publicactions where I am passenger
  Future getPublicationsByPassenger() async {
    QuerySnapshot snapshot = await publicacionesCollection
        .where(
          'pasajeros',
          arrayContains: FirebaseAuth.instance.currentUser!.uid,
        )
        .orderBy('fecha')
        .get();
    return snapshot.docs;
  }

  //
  Future softDeletePublication(String uid) async {
    await publicacionesCollection.doc(uid).update({
      'deleted': true,
    });
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

  //get passengers from a publication
  Future getPassengersFromPublication(String uid) async {
    QuerySnapshot snapshotReservas =
        await reservasCollection.where('publicacion', isEqualTo: uid).get();

    List<String> passengers = [];

    if (snapshotReservas.docs.isNotEmpty) {
      for (var reserva in snapshotReservas.docs) {
        passengers.add(reserva['pasajero']);
      }
      QuerySnapshot snapshotUsuarios =
          await usuarioCollection.where('uid', whereIn: passengers).get();
      return snapshotUsuarios.docs;
    }

    return [];
  }

  //check if publication is full
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

  //save reservation
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

  //delete reservation
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

  //create chat
  Future createChat(String uidConductor, String uidPasajero) async {
    final id = chatsCollection.doc().id;
    await chatsCollection.doc(id).set({
      'conductor': uidConductor,
      'pasajero': uidPasajero,
      'ultimoMensaje': '',
      'ultimoMensajeLeido': false,
      'emisorUltimoMensaje': '',
      'fechaUltimoMensaje': '',
      'pasajeroEnChat': false,
      'conductorEnChat': false,
      'uid': id,
    });

    final idMensaje = chatsCollection.doc(id).collection('mensajes').doc().id;
    await chatsCollection.doc(id).collection('mensajes').doc(idMensaje).set({
      'mensaje': '',
      'emisor': '',
      'fecha': DateTime.now().millisecondsSinceEpoch,
      'leido': true,
      'uid': idMensaje,
    });
  }

  //get chat from publication and if it doesn't exist, create it
  Future getChatFromPublication(String uidConductor, String uidPasajero) async {
    QuerySnapshot snapshot = await chatsCollection
        .where('conductor', isEqualTo: uidConductor)
        .where('pasajero', isEqualTo: uidPasajero)
        .get();

    if (snapshot.docs.isNotEmpty) {
      if (uidConductor == FirebaseAuth.instance.currentUser!.uid) {
        await chatsCollection.doc(snapshot.docs[0]['uid']).update({
          'conductorEnChat': true,
          'ultimoMensajeLeido': snapshot.docs[0]['emisorUltimoMensaje'] !=
                  FirebaseAuth.instance.currentUser!.uid
              ? true
              : false,
        });
      } else {
        await chatsCollection.doc(snapshot.docs[0]['uid']).update({
          'pasajeroEnChat': true,
          'ultimoMensajeLeido': snapshot.docs[0]['emisorUltimoMensaje'] !=
                  FirebaseAuth.instance.currentUser!.uid
              ? true
              : false,
        });
      }

      return snapshot.docs;
    } else {
      await createChat(uidConductor, uidPasajero);
      return await getChatFromPublication(
        uidConductor,
        uidPasajero,
      );
    }
  }

  //check when a user exits a chat
  Future exitChat(String uidChat, String uidUser) async {
    DocumentSnapshot snapshot = await chatsCollection.doc(uidChat).get();
    if (snapshot['conductor'] == uidUser) {
      await chatsCollection.doc(uidChat).update({
        'conductorEnChat': false,
      });
    } else {
      await chatsCollection.doc(uidChat).update({
        'pasajeroEnChat': false,
      });
    }
  }

  //get my chats
  Future getMyChats() async {
    QuerySnapshot snapshot = await chatsCollection
        .where(
          'participantes',
          arrayContains: FirebaseAuth.instance.currentUser!.uid,
        )
        .get();
    return snapshot.docs;
  }

  //get my chat with a passenger
  Future getChatsWithPassenger(String uidPasajero) async {
    QuerySnapshot snapshot = await chatsCollection
        .where('pasajero', isEqualTo: uidPasajero)
        .where(
          'conductor',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .orderBy('fechaUltimoMensaje', descending: true)
        .get();
    return snapshot.docs;
  }

  //get my chat with a driver
  Future getChatsWithDriver(String uidConductor) async {
    QuerySnapshot snapshot = await chatsCollection
        .where('conductor', isEqualTo: uidConductor)
        .where('pasajero', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('fechaUltimoMensaje', descending: true)
        .get();
    return snapshot.docs;
  }

  //create message
  Future createMessage(
    String uidChat,
    String mensaje,
    String emisor,
    String receptor,
  ) async {
    DocumentSnapshot snapshot = await chatsCollection.doc(uidChat).get();

    final id = chatsCollection.doc(uidChat).collection('mensajes').doc().id;
    await chatsCollection.doc(uidChat).collection('mensajes').doc(id).set({
      'mensaje': mensaje,
      'emisor': emisor,
      'fecha': DateTime.now().millisecondsSinceEpoch,
      'uid': id,
    });

    await chatsCollection.doc(uidChat).update({
      'ultimoMensaje': mensaje,
      'emisorUltimoMensaje': emisor,
      'fechaUltimoMensaje': DateTime.now().millisecondsSinceEpoch,
      'ultimoMensajeLeido':
          receptor == snapshot['conductor'] && snapshot['conductorEnChat'] ||
                  receptor == snapshot['pasajero'] && snapshot['pasajeroEnChat']
              ? true
              : false,
    });

    //check if receptor is in chat
    if (snapshot['conductor'] == receptor && !snapshot['conductorEnChat'] ||
        snapshot['pasajero'] == receptor && !snapshot['pasajeroEnChat']) {
      final receiver = await usuarioCollection.doc(receptor).get();
      final sender = await usuarioCollection.doc(emisor).get();
      NotificationsProvider().sendPushNotification(
        receiver['pushToken'],
        sender['nombreCompleto'],
        mensaje,
      );
    }
  }

  //get mensajes de un chat
  Stream getMessages(String uidChat) {
    return chatsCollection
        .doc(uidChat)
        .collection('mensajes')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  //delete mensaje
  Future deleteMessage(String uidChat, String uidMensaje) async {
    await chatsCollection
        .doc(uidChat)
        .collection('mensajes')
        .doc(uidMensaje)
        .delete();
  }
}
