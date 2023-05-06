import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/screens/menu_principal_screen.dart';
import 'package:zonzacar/widgets/widgets.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({
    Key? key,
    required this.passenger,
    required this.driver,
    required this.isDriver,
  }) : super(key: key);

  final String passenger;
  final String driver;
  final bool isDriver;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  DatabaseProvider databaseProvider = DatabaseProvider();
  TextEditingController messageController = TextEditingController();

  String? chatId;
  bool isLoading = false;
  dynamic passenger;
  dynamic driver;

  void getChatFromDriverAndPassenger() async {
    try {
      setState(() {
        isLoading = true;
      });

      await databaseProvider
          .getChatFromPublication(
            widget.driver,
            widget.passenger,
          )
          .then((value) => setState(() {
                chatId = value[0]['uid'];
              }));

      await databaseProvider
          .getUserByUid(
            widget.driver,
          )
          .then((value) => setState(() {
                driver = value;
              }));

      await databaseProvider
          .getUserByUid(
            widget.passenger,
          )
          .then((value) => setState(() {
                passenger = value;
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
    getChatFromDriverAndPassenger();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await databaseProvider.exitChat(
          chatId!,
          FirebaseAuth.instance.currentUser!.uid,
        );
        return true;
      },
      child: Scaffold(
        appBar: isLoading
            ? null
            : AppBar(
                elevation: 0,
                title: widget.isDriver
                    ? Text(
                        passenger[0]['nombreCompleto'],
                        maxLines: 2,
                      )
                    : Text(
                        driver[0]['nombreCompleto'],
                        maxLines: 2,
                      ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    await databaseProvider.exitChat(
                      chatId!,
                      FirebaseAuth.instance.currentUser!.uid,
                    );
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MenuScreen(
                            initialIndex: 3,
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
                centerTitle: true,
                actions: [
                  widget.isDriver
                      ? Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: UserImage(
                            userImage: passenger[0]['imagenPerfil'] != '' &&
                                    passenger[0]['imagenPerfil'] != null
                                ? passenger[0]['imagenPerfil']
                                : '',
                            radiusOutterCircle: 22,
                            radiusImageCircle: 20,
                            iconSize: 20,
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: UserImage(
                            userImage: driver[0]['imagenPerfil'] != '' &&
                                    driver[0]['imagenPerfil'] != null
                                ? driver[0]['imagenPerfil']
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
                      child: Messages(
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
                                controller: messageController,
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
    final mensaje = messageController.text.trim();
    final emisor = widget.isDriver ? widget.driver : widget.passenger;
    final receptor = widget.isDriver ? widget.passenger : widget.driver;
    if (messageController.text.trim().isNotEmpty) {
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

    messageController.clear();
  }
}

class Messages extends StatelessWidget {
  const Messages({
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
          return ListView.builder(
            reverse: true,
            itemCount: mensajes.length,
            itemBuilder: (context, index) {
              return index == mensajes.length - 1
                  ? Container()
                  : MessageTile(
                      hour: mensajes[index]['fecha'] > today
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
                      message: mensajes[index]['mensaje'],
                      sender: mensajes[index]['emisor'],
                      sendByMe: widget.isDriver
                          ? mensajes[index]['emisor'] == widget.driver
                          : mensajes[index]['emisor'] == widget.passenger,
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
