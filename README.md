# ZonzaCar

![logo](https://user-images.githubusercontent.com/94843020/236709677-0bc50ff7-ed39-4dba-9bb0-d7df8dfdd21a.png)

ZonzaCar es una plataforma que permite a sus usuarios publicar o reservar trayectos para compartir coche, se creó para intentar reducir la huella de carbono de los estudiantes del CIFP Zonzamas (Arrecife, Lanzarote, España) así como para brindarles otra alternativa de transporte.

## Tabla de contenidos

- [Características](#características)
- [Instalación](#instalación)
- [Uso](#uso)
- [Enlaces](#enlaces)

## Características

![1683498121373](https://user-images.githubusercontent.com/94843020/236709712-817c95ed-efeb-4664-a0dc-3f293154fc28.jpg)
![1683498121395](https://user-images.githubusercontent.com/94843020/236709715-6237c1c9-a536-45e9-9370-7bc9c0e2e17d.jpg)
![1683498121418](https://user-images.githubusercontent.com/94843020/236709717-3cbf9236-f361-4cf5-aa22-11d70c037354.jpg)
![1683498121440](https://user-images.githubusercontent.com/94843020/236709718-6fcf36dc-440c-401d-9b77-5f145d508bef.jpg)
![1683498121465](https://user-images.githubusercontent.com/94843020/236709719-bdf797b6-2811-44e9-8509-92258b3b6775.jpg)
![1683498121327](https://user-images.githubusercontent.com/94843020/236709721-02d8b4be-4d9f-4a4a-a556-8278f4f524a7.jpg)
![1683498121350](https://user-images.githubusercontent.com/94843020/236709722-4c51a3c0-8a3c-498c-be38-111effdf6f96.jpg)

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
3. Configura un proyecto de Firebase y habilita Firebase Auth, Firebase Cloud Messaging y Firebase Cloud Firestore
4. Crea un archivo `.env` en el directorio raíz.
5. Agrega las siguientes variables de entorno al archivo `.env`:

![image](https://user-images.githubusercontent.com/94843020/236706857-d94a221e-e31e-4aa4-937c-d68cee817436.png)

6. En la ruta `android/app/src/main/AndroidManifest.xml` añade el siguiente código con tu API Key de Google

![image](https://user-images.githubusercontent.com/94843020/236702702-b0cbfd73-d169-49c0-8ee3-a4ca20f2f5a9.png)


7. En la ruta `ios/Runner/AppDelegate.swift` añade la siguiente línea de código con tu API Key de Google
            
![image](https://user-images.githubusercontent.com/94843020/236702639-354026ae-678f-463e-9158-3c0188226a08.png)
            

8. Ejecuta la aplicación en tu emulador o dispositivo físico: `flutter run`

Nota: Deberás obtener tu propia clave de API de Google Maps y los valores de configuración de Firebase para que la aplicación funcione correctamente.

## Uso

Para usar ZonzaCar, sigue estos pasos:

1. Ejecuta la aplicación en tu emulador o dispositivo físico: `flutter run` || opcionalmente también podrás descargar la [apk](https://drive.google.com/file/d/1rUiRuVp0Wgq6v336U99WZWU0eUOug8pu/view?usp=share_link)
2. Accede a la página de inicio de sesión y registra una nueva cuenta o inicia sesión con una existente.
3. Busca coches disponibles por ubicación y rango de fechas.
4. Selecciona una publicación para ver más detalles e información de precios.
5. Reserva un coche.
6. Utiliza la mensajería dentro de la aplicación para comunicarte con el propietario del coche y coordinar la recogida y entrega.
7. Gestiona tus reservas y publicaciones en la aplicación.

## Enlaces y descargas

[Fase de análisis](https://docs.google.com/document/d/14CK8XM1k-dHkf6uLCWiHcmMnxwWX5XMX_tMFQRRyRSE/edit?usp=sharing)\
[Diagrama de clases UML](https://drive.google.com/file/d/1DVjSWmkDRvXYcMOwM_TE0vweYVYE_oxK/view?usp=share_link)\
[Diseño](https://wireframepro.mockflow.com/view/MU2Ioh1mgpb)\
[JSON Estructura BBDD](https://drive.google.com/file/d/1LV9SxkmxYlW5IrEQlCl38TbS98glXJtg/view?usp=share_link)\
[Vídeo presentación](https://www.youtube.com/watch?v=WlRWOvd4sd0)\
[APK Zonzacar](https://drive.google.com/file/d/1rUiRuVp0Wgq6v336U99WZWU0eUOug8pu/view?usp=share_link)
