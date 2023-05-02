//Contantes para los colores de los coches
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
