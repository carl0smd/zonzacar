import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:zonzacar/models/models.dart';

import '../models/directions_response.dart';

//CLASS TO HELP WITH GOOGLE SERVICES
class GoogleServicesProvider {
  final String _apiKey = dotenv.env['GOOGLE_API_KEY']!;
  final String authority = "maps.googleapis.com";
  final String radius = '30000';
  final String location = '29.03576,-13.65051';
  final String components = "country:es";
  final String language = "es";

  //get predictions

  Future<List<Prediction>> placeAutocomplete(String input, String token) async {
    const String unencodedPath = "/maps/api/place/autocomplete/json";
    Uri request = Uri.https(authority, unencodedPath, {
      'input': input,
      'key': _apiKey,
      'radius': radius,
      'location': location,
      'strictbounds': 'true',
      'components': components,
      'language': language,
      'sessiontoken': token,
    });
    final response = await http.get(request);

    if (response.statusCode == 200) {
      final predictionsResponse =
          PredictionsResponse.fromRawJson(response.body);
      return predictionsResponse.predictions;
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  // get place coordinates

  Future<Location> placeCoordinates(String placeId) async {
    Uri request = Uri.https(authority, '/maps/api/place/details/json', {
      'place_id': placeId,
      'key': _apiKey,
      'fields': 'geometry',
    });
    final response = await http.get(request);
    if (response.statusCode == 200) {
      final predictionDetailsResponse =
          PredictionDetailsResponse.fromRawJson(response.body);
      return predictionDetailsResponse.result.geometry.location;
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  // get polyline, distance and duration

  Future<List<String>> getPolylineAndDistanceAndDuration(
    String origin,
    String destination,
  ) async {
    Uri request = Uri.https(authority, '/maps/api/directions/json', {
      'origin': origin,
      'destination': destination,
      'mode': 'driving',
      'key': _apiKey,
    });
    final response = await http.get(request);
    if (response.statusCode == 200) {
      final directionsResponse = DirectionsResponse.fromRawJson(response.body);

      if (directionsResponse.routes.isNotEmpty) {
        return [
          directionsResponse.routes[0].overviewPolyline.points,
          directionsResponse.routes[0].legs[0].distance.text,
          directionsResponse.routes[0].legs[0].duration.text,
        ];
      } else {
        // this is to handle the case where the user enters a place that is not reachable by car for example La Graciosa
        return ['', ''];
      }
    } else {
      throw Exception('Failed to load predictions');
    }
  }
}
