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

//CONSTANTS FOR TYPE OF FUEL
class FuelConstants {
  static List<String> fuels = [
    'Gasolina',
    'Diésel',
    'Híbrido',
    'Eléctrico',
  ];

//Teniendo en cuenta un consumo de 5.5l/km en coches gasolina, diésel y híbrido y 18kWh/km en coche eléctrico
  static final emitions = {
    //2.3 kg/C02 por litro * 5.5/100
    'gasolina': 0.126, //por km
    //2.7 kg/C02 por litro * 5.5/100
    'diesel': 0.149, //por km
    //1.8 kg/C02 por litro * 5.5/100
    'hibrido': 0.100, //por km
    //0.138 kg/C02 por kWh * 18/100
    'electrico': 0.025, //por km
  };
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
