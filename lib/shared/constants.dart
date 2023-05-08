//CONSTANTS FOR COLORS
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

//CONSTANT FOR PRICE
class PriceConstants {
  //AVERAGE PRICE PER KM IN SPAIN IN 2023
  static double pricePerKm = 0.20;
}

//CONSTANTS FOR DATES
class DateConstants {
  static DateTime initialDate = DateTime.now().weekday == 6
      ? DateTime.now().add(const Duration(days: 2))
      : DateTime.now().weekday == 7
          ? DateTime.now().add(const Duration(days: 1))
          : DateTime.now();
}
