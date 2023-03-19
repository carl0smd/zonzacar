
import 'package:http/http.dart' as http;
import 'package:zonzacar/models/predictions_response.dart';

class GooglePlacesProvider{

  final String apiKey = "AIzaSyChq95jpxmwNComEH2yuE7E_RjES__r2JM";
  final String authority = "maps.googleapis.com";
  final String unencodedPath = "/maps/api/place/autocomplete/json";
  final String radius = '30000';
  final String location = '29.03576,-13.65051';
  final String components = "country:es";
  final String language = "es";
  
  Future<List<Prediction>> placeAutocomplete(String input, String token) async {
    Uri request = Uri.https(authority, unencodedPath, {
      'input': input,
      'key': apiKey,
      'radius': radius,
      'location': location,
      'strictbounds': 'true',
      'components': components,
      'language': language,
      'sessiontoken': token,
    });
    print(request);
    //get response with CORS enabled 
    final response = await http.get(request);
    if (response.statusCode == 200) {
      final predictionsResponse = PredictionsResponse.fromRawJson(response.body);
      return predictionsResponse.predictions;
    } else {
      throw Exception('Failed to load predictions');
    }

  }
}