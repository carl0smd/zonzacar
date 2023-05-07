# ZonzaCar

ZonzaCar es una plataforma que permite a sus usuarios publicar o reservar trayectos para compartir coche, se creó para intentar reducir la huella de carbono de los estudiantes del CIFP Zonzamas (Arrecife, Lanzarote, España) así como para brindarles otra alternativa de transporte.

## Tabla de contenidos

- [Características](#características)
- [Instalación](#instalación)
- [Uso](#uso)
- [Enlaces](#enlaces)

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
3. Configura un proyecto de Firebase y habilita Firebase Auth, Firebase Cloud Messaging y Firebase Cloud Firestore
4. Crea un archivo `.env` en el directorio raíz.
5. Agrega las siguientes variables de entorno al archivo `.env`:

GOOGLE_API_KEY=<tu-clave-api-de-google-maps>
MESSAGE_API_KEY=<tu-clave-api-de-messaging-de-firebase>

6. Ejecuta la aplicación en tu emulador o dispositivo físico: `flutter run`

Nota: Deberás obtener tu propia clave de API de Google Maps y los valores de configuración de Firebase para que la aplicación funcione correctamente.

## Uso

Para usar ZonzaCar, sigue estos pasos:

1. Ejecuta la aplicación en tu emulador o dispositivo físico: `flutter run` || opcionalmente también podrás descargar la apk: 
2. Accede a la página de inicio de sesión y registra una nueva cuenta o inicia sesión con una existente.
3. Busca coches disponibles por ubicación y rango de fechas.
4. Selecciona una publicación para ver más detalles e información de precios.
5. Reserva un coche.
6. Utiliza la mensajería dentro de la aplicación para comunicarte con el propietario del coche y coordinar la recogida y entrega.
7. Gestiona tus reservas y publicaciones en la aplicación.

## Enlaces y descargas

[Fase de análisis](https://docs.google.com/document/d/14CK8XM1k-dHkf6uLCWiHcmMnxwWX5XMX_tMFQRRyRSE/edit?usp=sharing)\
[Diagráma de clases UML](https://drive.google.com/file/d/1DVjSWmkDRvXYcMOwM_TE0vweYVYE_oxK/view?usp=share_link)\
