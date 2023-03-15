import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zonzacar/providers/auth_provider.dart';
import 'package:zonzacar/providers/database_provider.dart';
import 'package:zonzacar/screens/login_screen.dart';
import 'package:zonzacar/widgets/widgets.dart';

class PerfilScreen extends StatefulWidget {
   
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  String userName = '';
  String userEmail = '';
  String userImage = '';

  Future _getCurrentUser() async {
    await FirebaseFirestore.instance.collection('usuarios')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .get()
    .then((snapshot) async {
      if (snapshot.exists) {
        setState(() {
          userEmail = snapshot.data()!['email'];
          userName = snapshot.data()!['nombreCompleto'];
          userImage = snapshot.data()!['imagenPerfil'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {

    AuthProvider authProvider = AuthProvider();
    DatabaseProvider databaseProvider = DatabaseProvider();

    void uploadImage(camara) async {
      final image = await ImagePicker().pickImage(
        source: camara == true ? ImageSource.camera : ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 75,
      );
      
      if (image == null) return;
      Reference ref = FirebaseStorage.instance.ref().child("fotoperfil$userEmail.jpg");

      await ref.putFile(File(image.path));
      ref.getDownloadURL().then((value) {
        setState(() {
          userImage = value;
          databaseProvider.storeProfileImage(userImage);
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          Row(
            children: [

              IconButton(
                onPressed: () {
                  authProvider.logOut();
                  Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
                }, 
                icon: const Icon(Icons.logout)
              )
            ],
          ),
          
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 10,),
                        Text(userEmail),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black87,
                      radius: 52,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50,
                        child: userImage == '' ? 
                        const Icon(Icons.person, size: 50,)
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(userImage, fit: BoxFit.cover, width: 100, height: 100,),
                        ),
                      )
                    ),
                  ],
                ),
                TextButton(
                  child: const Text('Editar foto de perfil', style: TextStyle(fontSize: 16, color: Colors.green)),
                  onPressed: () async {
                    return editarFotoDialog(context, uploadImage);
                  },
                ),
                TextButton(
                  child: const Text('Editar nombre', style: TextStyle(fontSize: 16, color: Colors.green)),
                  onPressed: () async {
                    return _editarNombreDialog(context, databaseProvider);
                  },
                ),
                const Divider(thickness: 1,),
                const Text('Vehículos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                TextButton(
                  child: const Text('Añadir vehículo', style: TextStyle(fontSize: 16, color: Colors.green)),
                  onPressed: () {
                    print('Editar datos');
                  },
                ),
                const Divider(thickness: 1,),
                TextButton(
                  child: const Text('Eliminar cuenta', style: TextStyle(fontSize: 16, color: Colors.red)),
                  onPressed: () {
                    print('Cuenta eliminada');
                  },
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  Future<void> _editarNombreDialog(BuildContext context, DatabaseProvider databaseProvider) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        if (Platform.isAndroid) {
          return AlertDialog(
            title: const Text('Editar nombre', textAlign: TextAlign.center,),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nombre',
                      ),
                      validator: (value) {
                        return RegExp(r"^[A-Za-záéíóúüÁÉÍÓÚÜñÑ]{2,}(?:\s[A-Za-záéíóúüÁÉÍÓÚÜñÑ]{2,})?$").hasMatch(value!.trim())
                        ? null
                        : 'Introduce un nombre válido';
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Guardar'),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            setState(() {});
                            userName = nameController.text.trim();
                            databaseProvider.updateUserName(userName);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return CupertinoAlertDialog(
          title: const Text('Editar nombre', textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Nombre',
                    ),
                    validator: (value) {
                      return RegExp(r"^[A-Za-záéíóúüÁÉÍÓÚÜñÑ]{2,}(?:\s[A-Za-záéíóúüÁÉÍÓÚÜñÑ]{2,})?$").hasMatch(value!.trim())
                      ? null
                      : 'Introduce un nombre válido';
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Guardar'),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {});
                          userName = nameController.text.trim();
                          databaseProvider.updateUserName(userName);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}