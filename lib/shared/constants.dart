//Contantes para los colores de los coches
class ColorsConstants {
  static List<String> colors = [
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
class PriceConstants {
  //Precio medio de gasolina por kilómetro España 2023
  static double pricePerKm = 0.20;
}

//Constantes para las fechas
class DateConstants {
  //Si el día de la semana es sábado o domingo pasa al lunes
  static DateTime initialDate = DateTime.now().weekday == 6
      ? DateTime.now().add(const Duration(days: 2))
      : DateTime.now().weekday == 7
          ? DateTime.now().add(const Duration(days: 1))
          : DateTime.now();
}
