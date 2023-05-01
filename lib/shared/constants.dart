// Constantes para Firebase
// class FirebaseConstants {
//   static String apiKey = "AIzaSyCEFUhH1gsvZk9C-8w4Qjb6X0SR7FoG-C8";
//   static String appId = "1:1068722437145:web:fa9379baa6d9bc007ffe88";
//   static String authDomain = "zonzacar.firebaseapp.com";
//   static String messagingSenderId = "1068722437145";
//   static String projectId = "zonzacar";
//   static String storageBucket = "zonzacar.appspot.com";
// }

//Contantes para los colores
class ColoresConstants {
  static List<String> colores = [
    'Amarillo',
    'Azul',
    'Beige',
    'Blanco',
    'Dorado',
    'Gris',
    'Marrón',
    'Morado',
    'Naranja',
    'Negro',
    'Plateado',
    'Rojo',
    'Rosa',
    'Verde',
  ];
}

//Constantes para los precios
class PrecioConstants {
  //Precio medio de gasolina por kilómetro España 2023
  static double precioPorKm = 0.20;

  //15% de gastos de gestión para zonzaCar (costos de la api)
  static double porcentajeZonzaCar = 1.15;
}

//Constantes para las fechas
class FechaConstants {
  //Si el día de la semana es sábado o domingo pasa al lunes
  static DateTime initialDate = DateTime.now().weekday == 6
      ? DateTime.now().add(const Duration(days: 2))
      : DateTime.now().weekday == 7
          ? DateTime.now().add(const Duration(days: 1))
          : DateTime.now();
}
