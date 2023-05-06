import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zonzacar/helpers/helper_function.dart';
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
  AuthProvider authProvider = AuthProvider();
  DatabaseProvider databaseProvider = DatabaseProvider();
  List vehicles = [];
  bool _isCameraPermissionGranted = false;
  bool _isPhotosPermissionGranted = false;
  bool _isStoragePermissionGranted = false;

  void _askForCameraPermission() async {
    final status = await Permission.camera.request();
    switch (status) {
      case PermissionStatus.granted:
        setState(() {
          _isCameraPermissionGranted = true;
        });
        break;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        setState(() {
          _isCameraPermissionGranted = false;
        });
        openAppSettings();
    }
  }

  void _askForPhotosPermission() async {
    final status = await Permission.photos.request();
    switch (status) {
      case PermissionStatus.granted:
        setState(() {
          _isPhotosPermissionGranted = true;
        });
        break;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        setState(() {
          _isPhotosPermissionGranted = false;
        });
        openAppSettings();
    }
  }

  void _askForStoragePermission() async {
    final status = await Permission.storage.request();
    switch (status) {
      case PermissionStatus.granted:
        setState(() {
          _isStoragePermissionGranted = true;
        });
        break;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        setState(() {
          _isStoragePermissionGranted = false;
        });
        openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    databaseProvider.getCurrentUser().then((value) {
      setState(() {
        userName = value.docs[0].data()['nombreCompleto'];
        userEmail = value.docs[0].data()['email'];
        userImage = value.docs[0].data()['imagenPerfil'];
      });
    });
    databaseProvider.getVehicles().then((value) {
      setState(() {
        vehicles.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    void uploadImage(camara) async {
      if (camara && _isCameraPermissionGranted == false) {
        _askForCameraPermission();
        if (_isCameraPermissionGranted == false) return;
      }
      if (!camara && Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          if (_isStoragePermissionGranted == false) {
            _askForStoragePermission();
            if (_isStoragePermissionGranted == false) return;
          }
        } else {
          if (_isPhotosPermissionGranted == false) {
            _askForPhotosPermission();
            if (_isPhotosPermissionGranted == false) return;
          }
        }
      }

      if (!camara && Platform.isIOS && _isPhotosPermissionGranted == false) {
        _askForPhotosPermission();
        if (_isPhotosPermissionGranted == false) return;
      }

      final image = await ImagePicker().pickImage(
        source: camara == true ? ImageSource.camera : ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 75,
      );

      if (image == null) return;
      Reference ref =
          FirebaseStorage.instance.ref().child("fotoperfil$userEmail.jpg");

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
          // Botón para salir de la sesión
          Row(
            children: [
              IconButton(
                onPressed: () {
                  authProvider.logOut();
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
              ),
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
                // Nombre de usuario, email y foto de perfil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre de usuario
                        SizedBox(
                          width: 220,
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Email
                        SizedBox(
                          width: 220,
                          child: Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Foto de perfil
                    UserImage(
                      userImage: userImage,
                      radiusOutterCircle: 52,
                      radiusImageCircle: 50,
                      iconSize: 50,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  thickness: 1,
                ),
                const Text(
                  'Datos',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                // Botón para editar la foto de perfil
                TextButton(
                  child: const Text(
                    'Editar foto de perfil',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  onPressed: () async {
                    return editImageDialog(context, uploadImage);
                  },
                ),
                // Botón para editar el nombre
                TextButton(
                  child: const Text(
                    'Editar nombre',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  onPressed: () async {
                    return _editNameDialog(context, databaseProvider);
                  },
                ),
                const Divider(
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Vehículos',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                // Botón para añadir un vehículo
                TextButton(
                  child: const Text(
                    'Añadir vehículo',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  onPressed: () async {
                    await addVehicleDialog(context, databaseProvider);
                    // Actualizar la lista de vehículos después de añadir uno nuevo
                    await databaseProvider.getVehicles().then((value) {
                      setState(() {
                        vehicles.clear();
                        vehicles.addAll(value);
                      });
                    });
                  },
                ),
                // Lista de vehículos
                Flexible(
                  child: ListView.builder(
                    itemCount: vehicles.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(
                          Icons.directions_car,
                          color: Colors.green,
                        ),
                        title: Text(vehicles[index]['marca'] +
                            ' ' +
                            vehicles[index]['modelo'] +
                            ' - ' +
                            vehicles[index]['color']),
                        subtitle: Text(vehicles[index]['matricula']),
                        trailing: IconButton(
                          onPressed: () async {
                            if (await databaseProvider
                                .deleteVehicle(vehicles[index]['uid'])) {
                              setState(() {
                                vehicles.removeAt(index);
                              });
                              if (mounted) {
                                showSnackbar(
                                  'Vehículo eliminado correctamente',
                                  context,
                                );
                              }
                            } else {
                              if (mounted) {
                                showSnackbar(
                                  'Error al eliminar, aún tienes publicaciones activas con este vehículo',
                                  context,
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Valoración',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                //rating
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder(
                  stream: databaseProvider.getCurrentUser().asStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final rating = snapshot.data.docs[0]['mediaValoraciones'];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.green,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          rating != 0
                              ? Text(
                                  rating.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Text(
                                  'Publica para obtener valoraciones',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                // Botón para eliminar la cuenta
                TextButton(
                  child: const Text(
                    'Eliminar cuenta',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DeleteAccountDialog(
                          authProvider: authProvider,
                          databaseProvider: databaseProvider,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dialog para editar nombre
  Future<void> _editNameDialog(
    BuildContext context,
    DatabaseProvider databaseProvider,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        if (Platform.isAndroid) {
          return AlertDialog(
            title: const Text(
              'Editar nombre',
              textAlign: TextAlign.center,
            ),
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
                        return RegExp(
                          r"^[A-Za-záéíóúüÁÉÍÓÚÜñÑ]{2,}(?:\s[A-Za-záéíóúüÁÉÍÓÚÜñÑ]{2,})?$",
                        ).hasMatch(value!.trim())
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
          title: const Text(
            'Editar nombre',
            textAlign: TextAlign.center,
          ),
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
                      return RegExp(
                        r"^[A-Za-záéíóúüÁÉÍÓÚÜñÑ]{2,}(?:\s[A-Za-záéíóúüÁÉÍÓÚÜñÑ]{2,})?$",
                      ).hasMatch(value!.trim())
                          ? null
                          : 'Introduce un nombre válido';
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.red),
                      ),
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
      },
    );
  }
}

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({
    super.key,
    required this.authProvider,
    required this.databaseProvider,
  });

  final AuthProvider authProvider;
  final DatabaseProvider databaseProvider;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  HelperFunctions helperFunctions = HelperFunctions();
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '¿Estás seguro?',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: !isLoading
            ? ListBody(
                children: [
                  const Text(
                    'Si eliminas tu cuenta, se eliminarán todos tus datos y no podrás recuperarlos',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Introduce tu contraseña para continuar',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Contraseña',
                      ),
                      obscureText: true,
                      //don't show the last character typed

                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Introduce tu contraseña';
                        } else if (value.length < 6) {
                          return 'Debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: !isLoading
              ? const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                )
              : Container(),
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              setState(() {
                isLoading = true;
              });
              await widget.authProvider
                  .reauthenticate(passwordController.text)
                  .then((value) async {
                switch (value) {
                  case true:
                    await widget.databaseProvider.deleteUser(true);
                    if (mounted) {
                      showSnackbar('Cuenta eliminada', context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        'login',
                        (route) => false,
                      );
                    }
                    break;
                  case 'wrong-password':
                    setState(() {
                      isLoading = false;
                    });
                    showSnackbar('Contraseña incorrecta', context);
                    break;
                  case 'too-many-requests':
                    showSnackbar(
                      'Demasiados intentos, para poder acceder a su cuenta renueve la contraseña',
                      context,
                      duration: const Duration(seconds: 10),
                    );
                    helperFunctions.saveUserLoggedInStatus(false);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      'login',
                      (route) => false,
                    );
                    break;
                  default:
                    setState(() {
                      isLoading = false;
                    });
                    showSnackbar(
                      'Ha ocurrido un error, inténtelo más tarde',
                      context,
                    );
                }
              });
            }
          },
          child: !isLoading
              ? const Text(
                  'Eliminar',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                )
              : Container(),
        ),
      ],
    );
  }
}
