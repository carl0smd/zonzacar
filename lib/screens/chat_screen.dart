import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zonzacar/screens/screens.dart';
import 'package:zonzacar/widgets/widgets.dart';

import '../providers/database_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DatabaseProvider databaseProvider = DatabaseProvider();

  bool isLoading = false;
  List<String> driversId = [];
  List<String> passengersId = [];

  void getConductoresYPasajeros() async {
    try {
      setState(() {
        isLoading = true;
      });

      await databaseProvider.getAllMyDrivers().then((value) {
        setState(() {
          passengersId = value;
        });
      });
      await databaseProvider.getAllMyPassengers().then((value) {
        setState(() {
          passengersId = value;
        });
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackbar('Hemos tenido un problema, intenta más tarde', context);
    }
  }

  @override
  void initState() {
    super.initState();
    getConductoresYPasajeros();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  tabs: [
                    Tab(text: 'Mis conductores'),
                    Tab(text: 'Mis pasajeros'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : driversId.isEmpty
                              ? const NoUsers()
                              : Users(
                                  databaseProvider: databaseProvider,
                                  usersId: driversId,
                                  isDriver: true,
                                ),

                      // Mis pasajeros
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : passengersId.isEmpty
                              ? const NoUsers()
                              : Users(
                                  databaseProvider: databaseProvider,
                                  usersId: passengersId,
                                  isDriver: false,
                                ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Users extends StatelessWidget {
  const Users({
    super.key,
    required this.databaseProvider,
    required this.usersId,
    required this.isDriver,
  });

  final DatabaseProvider databaseProvider;
  final List<String> usersId;
  final bool isDriver;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseProvider.getAllUsersByUid(usersId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List users = snapshot.data as List;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                child: ListTile(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      withNavBar: false,
                      screen: ChatDetailsScreen(
                        pasajero: isDriver
                            ? FirebaseAuth.instance.currentUser!.uid
                            : users[index]['uid'],
                        conductor: isDriver
                            ? users[index]['uid']
                            : FirebaseAuth.instance.currentUser!.uid,
                        isConductor: !isDriver,
                      ),
                    );
                  },
                  leading: ImagenUsuario(
                    userImage: users[index]['imagenPerfil'],
                    radiusOutterCircle: 22,
                    radiusImageCircle: 20,
                    iconSize: 20,
                  ),
                  title: Text(
                    users[index]['nombreCompleto'],
                  ),
                  subtitle: isDriver
                      ? FutureBuilder(
                          future: databaseProvider
                              .getChatsWithDriver(users[index]['uid']),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List chat = snapshot.data as List;
                              return Text(
                                chat[0]['ultimoMensaje'],
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        )
                      : FutureBuilder(
                          future: databaseProvider
                              .getChatsWithPassenger(users[index]['uid']),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List chat = snapshot.data as List;
                              return Text(
                                chat[0]['ultimoMensaje'],
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                  trailing:
                      Icon(Icons.send, color: Theme.of(context).primaryColor),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class NoUsers extends StatelessWidget {
  const NoUsers({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.message_outlined,
            color: Colors.grey,
            size: 80.0,
          ),
          SizedBox(height: 10.0),
          Text(
            'No tienes chats',
            style: TextStyle(
              fontSize: 25.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
