//MODEL FOR PREDICTIONS DETAILS FROM THE RESPONSE OF GOOGLE PLACES API

import 'dart:convert';

PredictionDetailsResponse predictionDetailsResponseFromJson(String str) =>
    PredictionDetailsResponse.fromJson(json.decode(str));

String predictionDetailsResponseToJson(PredictionDetailsResponse data) =>
    json.encode(data.toJson());

class PredictionDetailsResponse {
  PredictionDetailsResponse({
    required this.htmlAttributions,
    required this.result,
    required this.status,
  });

  List<dynamic> htmlAttributions;
  Result result;
  String status;

  factory PredictionDetailsResponse.fromRawJson(String str) =>
      PredictionDetailsResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PredictionDetailsResponse.fromJson(Map<String, dynamic> json) =>
      PredictionDetailsResponse(
        htmlAttributions:
            List<dynamic>.from(json["html_attributions"].map((x) => x)),
        result: Result.fromJson(json["result"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "html_attributions": List<dynamic>.from(htmlAttributions.map((x) => x)),
        "result": result.toJson(),
        "status": status,
      };
}

class Result {
  Result({
    required this.geometry,
  });

  Geometry geometry;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        geometry: Geometry.fromJson(json["geometry"]),
      );

  Map<String, dynamic> toJson() => {
        "geometry": geometry.toJson(),
      };
}

class Geometry {
  Geometry({
    required this.location,
    required this.viewport,
  });

  Location location;
  Viewport viewport;

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        location: Location.fromJson(json["location"]),
        viewport: Viewport.fromJson(json["viewport"]),
      );

  Map<String, dynamic> toJson() => {
        "location": location.toJson(),
        "viewport": viewport.toJson(),
      };
}

class Location {
  Location({
    required this.lat,
    required this.lng,
  });

  double lat;
  double lng;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class Viewport {
  Viewport({
    required this.northeast,
    required this.southwest,
  });

  Location northeast;
  Location southwest;

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
        northeast: Location.fromJson(json["northeast"]),
        southwest: Location.fromJson(json["southwest"]),
      );

  Map<String, dynamic> toJson() => {
        "northeast": northeast.toJson(),
        "southwest": southwest.toJson(),
      };
}
