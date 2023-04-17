
import 'package:http/http.dart' as http;
import 'package:zonzacar/models/models.dart';

import '../models/directions_response.dart';

class GoogleServicesProvider{

  final String apiKey = "AIzaSyChq95jpxmwNComEH2yuE7E_RjES__r2JM";
  final String authority = "maps.googleapis.com";
  final String radius = '30000';
  final String location = '29.03576,-13.65051';
  final String components = "country:es";
  final String language = "es";
  
  Future<List<Prediction>> placeAutocomplete(String input, String token) async {
    const String unencodedPath = "/maps/api/place/autocomplete/json";
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
    final response = await http.get(request);
    
    if (response.statusCode == 200) {
      final predictionsResponse = PredictionsResponse.fromRawJson(response.body);
      print(response.body);
      // predictionsResponse.predictions.removeWhere((element) => element.description.toLowerCase().contains('graciosa'));
      return predictionsResponse.predictions;
    } else {
      throw Exception('Failed to load predictions');
    }

  }

  Future<Location> placeCoordinates(String placeId) async {
    Uri request = Uri.https(authority, '/maps/api/place/details/json', {
      'place_id': placeId,
      'key': apiKey,
      'fields': 'geometry',
    });
    final response = await http.get(request);
    if (response.statusCode == 200) {
      final predictionDetailsResponse = PredictionDetailsResponse.fromRawJson(response.body);
      return predictionDetailsResponse.result.geometry.location;
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<List<String>> getPolylineAndDistance(String origin, String destination) async {
    Uri request = Uri.https(authority, '/maps/api/directions/json', {
      'origin': origin,
      'destination': destination,
      'key': apiKey,
    });
    final response = await http.get(request);
    if (response.statusCode == 200) {
      final directionsResponse = DirectionsResponse.fromRawJson(response.body);

      if (directionsResponse.routes.isNotEmpty) {
        return [directionsResponse.routes[0].overviewPolyline.points, directionsResponse.routes[0].legs[0].distance.text];
      } else {
        return ['',''];
      }
    } else {
      throw Exception('Failed to load predictions');
    }
  }
}