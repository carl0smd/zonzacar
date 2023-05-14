# ZonzaCar

![logo](https://user-images.githubusercontent.com/94843020/236709677-0bc50ff7-ed39-4dba-9bb0-d7df8dfdd21a.png)

ZonzaCar es una plataforma que permite a sus usuarios publicar o reservar trayectos para compartir coche, se creó para intentar reducir la huella de carbono de los estudiantes del CIFP Zonzamas (Arrecife, Lanzarote, España) así como para brindarles otra alternativa de transporte.

# Enlaces y descargas

[Fase de análisis](https://docs.google.com/document/d/14CK8XM1k-dHkf6uLCWiHcmMnxwWX5XMX_tMFQRRyRSE/edit?usp=sharing)\
[Diagrama de clases UML](https://drive.google.com/file/d/1DVjSWmkDRvXYcMOwM_TE0vweYVYE_oxK/view?usp=share_link)\
[Diseño](https://wireframepro.mockflow.com/view/MU2Ioh1mgpb)\
[JSON Estructura BBDD](https://drive.google.com/file/d/1LV9SxkmxYlW5IrEQlCl38TbS98glXJtg/view?usp=share_link)\
[Vídeo presentación](https://www.youtube.com/watch?v=WlRWOvd4sd0)\
[Descargar APK desde Play Store](https://play.google.com/store/apps/details?id=com.carl0smd.zonzacar&hl=es_419)\

## Tabla de contenidos

- [Características](#características)
- [Instalación](#instalación)
- [Uso](#uso)
- [Capturas](#capturas)

## Características

- Autenticación y registro de usuarios
- Búsqueda de coches disponibles por ubicación y rango de fechas
- Publicar trayectos
- Ver detalles y precios de publicaciones de usuarios
- Reservar y gestionar reservas de trayectos
- Integración con Google Maps para búsqueda basada en ubicación
- Mensajería dentro de la aplicación entre propietarios de coches y pasajeros
- Notificaciones push

## Instalación

Para instalar ZonzaCar, sigue estos pasos:

1. Clona el repositorio: `git clone https://github.com/carl0smd/zonzacar.git`

2. Instala las dependencias: `flutter pub get`

Los pasos 3 y 4 son opcionales, podrás conectarte a mi proyecto de Firebase sin tener que crear uno. Sin embargo si no haces esto no podrás usar la funcionalidad de notificaciones, ya que necesitarás una API key la cuál no proporcionaré.

3. (*Opcional*) Configura un proyecto de Firebase y vincúlalo a tu app, puedes seguir [este tutorial](https://www.youtube.com/watch?v=sz4slPFwEvs) y sustituye los archivos de google-services.json por los generados.

4. (*Opcional*) En tu proyecto de Firebase habilita Firebase Authentication, Firebase Storage, Firebase Firestore Database y Firebase Cloud Messaging (Obtén una Api key de este). [Cómo obtener una API key de Cloud Messaging](https://youtu.be/6hSrjp3dqCo?t=38)

5. Si ya tienes cuenta como Google developer ve a la cloud.console en caso contrario procede a crear una cuenta.

6. En la cloud console crea un nuevo proyecto o en caso de haber creado el proyecto de Firebase podrás utilizarlo desde ahí. Con el proyecto seleccionado ve a Credenciales -> Crear credenciales -> Clave de API, y genera tu API key de Google

![image](https://user-images.githubusercontent.com/94843020/236816773-25e4fbfe-71ce-4b55-8c80-be2a7a36c2d5.png)


7. Crea un archivo `.env` en el directorio raíz.

8. Agrega las siguientes variables de entorno al archivo `.env`:

![image](https://user-images.githubusercontent.com/94843020/236706857-d94a221e-e31e-4aa4-937c-d68cee817436.png)

9. En la ruta `android/app/src/main/AndroidManifest.xml` añade el siguiente código con tu API Key de Google

![image](https://user-images.githubusercontent.com/94843020/236702702-b0cbfd73-d169-49c0-8ee3-a4ca20f2f5a9.png)

10. (Opcional si quieres probar la app en iOs) En la ruta `ios/Runner/AppDelegate.swift` añade la siguiente línea de código con tu API Key de Google
            
![image](https://user-images.githubusercontent.com/94843020/236702639-354026ae-678f-463e-9158-3c0188226a08.png)
            
11. En `android/app/build.gradle` aumenta el minSdkVersion a `21`

![image](https://user-images.githubusercontent.com/94843020/236817701-179f6b3f-14c4-424f-93dc-4d734c695bed.png)

12. Ejecuta la aplicación en tu emulador o dispositivo físico: `flutter run`

## Uso

Para usar ZonzaCar, sigue estos pasos:

1. Ejecuta la aplicación en tu emulador o dispositivo físico: `flutter run` || opcionalmente también podrás descargar la [apk](https://play.google.com/store/apps/details?id=com.carl0smd.zonzacar&hl=es_419)
2. Accede a la página de inicio de sesión y registra una nueva cuenta o inicia sesión con una existente.
3. Busca coches disponibles por ubicación y rango de fechas.
4. Selecciona una publicación para ver más detalles e información de precios.
5. Reserva un coche.
6. Utiliza la mensajería dentro de la aplicación para comunicarte con el propietario del coche y coordinar la recogida y entrega.
7. Gestiona tus reservas y publicaciones en la aplicación.

## Capturas

![1683498121350](https://user-images.githubusercontent.com/94843020/236709871-bd2e3444-ae39-486a-9dee-fb7b8d60d442.jpg) ![1683498121373](https://user-images.githubusercontent.com/94843020/236709874-37ec4ff0-65ef-48e6-81f8-ccca5ae42a24.jpg)

![1683498121395](https://user-images.githubusercontent.com/94843020/236709875-18e8385f-989f-4c26-a908-3c0ae9ca1f2e.jpg)
![1683498121418](https://user-images.githubusercontent.com/94843020/236709876-ad201829-ad11-4aa9-bc17-9b18e2f48ab4.jpg)
![1683498121440](https://user-images.githubusercontent.com/94843020/236709878-2398ead6-af2d-489d-841a-b8d7efd434d4.jpg)
![1683498121465](https://user-images.githubusercontent.com/94843020/236709879-22e0d810-3b3b-4132-8eae-0eb2c341d9a8.jpg)
![1683498121327](https://user-images.githubusercontent.com/94843020/236709880-b35f605d-f4b1-49c2-8784-485e53ad931a.jpg)

