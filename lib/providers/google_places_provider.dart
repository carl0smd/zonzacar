
import 'package:http/http.dart' as http;
import 'package:zonzacar/models/predictions_response.dart';

class GooglePlacesProvider{

  final String apiKey = "AIzaSyChq95jpxmwNComEH2yuE7E_RjES__r2JM";
  final String baseUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
  final String components = "country:es";
  final String language = "es";
  
  Future<List<Prediction>> placeAutocomplete(String input, String token) async {
    String request = "$baseUrl?input=$input&key=$apiKey&sessiontoken=$token&components=$components&language=$language";
    print(request);
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final predictionsResponse = PredictionsResponse.fromRawJson(response.body);
      return predictionsResponse.predictions;
    } else {
      throw Exception('Failed to load predictions');
    }

  }
}