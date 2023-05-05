import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/widgets/widgets.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({
    Key? key,
    required this.pasajero,
    required this.conductor,
    required this.isConductor,
  }) : super(key: key);

  final String pasajero;
  final String conductor;
  final bool isConductor;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  DatabaseProvider databaseProvider = DatabaseProvider();
  TextEditingController mensajeController = TextEditingController();

  String? chatId;
  bool isLoading = false;
  dynamic pasajero;
  dynamic conductor;

  void getChatConductorYPasajero() async {
    try {
      setState(() {
        isLoading = true;
      });

      await databaseProvider
          .getChatFromPublication(
            widget.conductor,
            widget.pasajero,
          )
          .then((value) => setState(() {
                chatId = value[0]['uid'];
              }));

      await databaseProvider
          .getUserByUid(
            widget.conductor,
          )
          .then((value) => setState(() {
                conductor = value;
              }));

      await databaseProvider
          .getUserByUid(
            widget.pasajero,
          )
          .then((value) => setState(() {
                pasajero = value;
              }));
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
      showSnackbar(
        'Lo sentimos ha ocurrido un error, inténtelo más tarde',
        context,
      );
    }
  }

  void messageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          color: const Color(0xFF9D50DD),
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Messaging,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: true,
          backgroundColor: Colors.white,
          displayOnForeground: true,
          displayOnBackground: true,
          summary: '',
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    messageListener();
    getChatConductorYPasajero();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await databaseProvider.exitChat(
            chatId!, FirebaseAuth.instance.currentUser!.uid);
        return true;
      },
      child: Scaffold(
        appBar: isLoading
            ? null
            : AppBar(
                elevation: 0,
                title: widget.isConductor
                    ? Text(
                        pasajero[0]['nombreCompleto'],
                        maxLines: 2,
                      )
                    : Text(
                        conductor[0]['nombreCompleto'],
                        maxLines: 2,
                      ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    await databaseProvider.exitChat(
                      chatId!,
                      FirebaseAuth.instance.currentUser!.uid,
                    );
                    if (mounted) Navigator.pop(context);
                  },
                ),
                centerTitle: true,
                actions: [
                  widget.isConductor
                      ? Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: ImagenUsuario(
                            userImage: pasajero[0]['imagenPerfil'] != '' &&
                                    pasajero[0]['imagenPerfil'] != null
                                ? pasajero[0]['imagenPerfil']
                                : '',
                            radiusOutterCircle: 22,
                            radiusImageCircle: 20,
                            iconSize: 20,
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: ImagenUsuario(
                            userImage: conductor[0]['imagenPerfil'] != '' &&
                                    conductor[0]['imagenPerfil'] != null
                                ? conductor[0]['imagenPerfil']
                                : '',
                            radiusOutterCircle: 22,
                            radiusImageCircle: 20,
                            iconSize: 20,
                          ),
                        ),
                ],
              ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    Flexible(
                      child: Mensajes(
                        databaseProvider: databaseProvider,
                        chatId: chatId,
                        widget: widget,
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        color: Colors.grey[600],
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: mensajeController,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Envía un mensaje...',
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                sendMessage();
                              },
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  sendMessage() {
    final mensaje = mensajeController.text.trim();
    final emisor = widget.isConductor ? widget.conductor : widget.pasajero;
    final receptor = widget.isConductor ? widget.pasajero : widget.conductor;
    if (mensajeController.text.trim().isNotEmpty) {
      try {
        databaseProvider.createMessage(
          chatId!,
          mensaje,
          emisor,
          receptor,
        );
      } catch (e) {
        showSnackbar(
          'Lo sentimos ha ocurrido un error al enviar el mensaje',
          context,
        );
      }
    }

    mensajeController.clear();
  }
}

class Mensajes extends StatelessWidget {
  const Mensajes({
    super.key,
    required this.databaseProvider,
    required this.chatId,
    required this.widget,
  });

  final DatabaseProvider databaseProvider;
  final String? chatId;
  final ChatDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseProvider.getMessages(chatId!),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data.docs.length > 1) {
          List mensajes = snapshot.data.docs;
          final today = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ).millisecondsSinceEpoch;
          print(mensajes[0]['mensaje']);
          return ListView.builder(
            reverse: true,
            itemCount: mensajes.length,
            itemBuilder: (context, index) {
              return index == mensajes.length - 1
                  ? Container()
                  : MensajeTile(
                      hora: mensajes[index]['fecha'] > today
                          ? DateFormat.Hm().format(
                              DateTime.fromMillisecondsSinceEpoch(
                                mensajes[index]['fecha'],
                              ),
                            )
                          : DateFormat('dd/MM/yyyy H:m').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                mensajes[index]['fecha'],
                              ),
                            ),
                      mensaje: mensajes[index]['mensaje'],
                      emisor: mensajes[index]['emisor'],
                      enviadoPorMi: widget.isConductor
                          ? mensajes[index]['emisor'] == widget.conductor
                          : mensajes[index]['emisor'] == widget.pasajero,
                    );
            },
          );
        } else if (snapshot.hasData && snapshot.data.docs.length <= 1) {
          return Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.chat,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'No hay mensajes',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
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
