import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zonzacar/models/models.dart';
import 'package:zonzacar/providers/google_services_provider.dart';

//TESTS FOR GOOGLE SERVICES PROVIDER HTTP CALLS AND RESPONSES
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  group('GoogleServicesProvider', () {
    final provider = GoogleServicesProvider();

    test('placeAutocomplete returns list of predictions', () async {
      // Mock data
      const String mockInput = 'Calle';
      const String mockToken = 'abcd1234';

      // Call the function
      final predictions =
          await provider.placeAutocomplete(mockInput, mockToken);

      // Assertions
      expect(predictions, isA<List<Prediction>>());
      expect(predictions.length, greaterThan(0));
    });

    test(
      'placeAutocomplete returns empty list when street does not exist',
      () async {
        // Mock data
        const String mockInput = 'invalid_input';
        const String mockToken = 'abcd1234';

        // Call the function
        final predictions =
            await provider.placeAutocomplete(mockInput, mockToken);

        // Assertions
        expect(predictions, isA<List<Prediction>>());
        expect(predictions, isEmpty);
      },
    );

    test('placeCoordinates returns location coordinates', () async {
      // Mock data C. Islandia, 13, 35510 Tías, Las Palmas, España
      const String mockPlaceId = 'ChIJueCrMt4lRgwRvitpD3aAw84';

      // Call the function
      final location = await provider.placeCoordinates(mockPlaceId);

      // Assertions
      expect(location, isA<Location>());
      expect(location.lat, isNotNull);
      expect(location.lng, isNotNull);
    });

    test(
      'getPolylineAndDistanceAndDuration returns expected values for valid origin and destination',
      () async {
        // Mock data
        const String mockOrigin = '28.927109376904205, -13.642229944649179';
        const String mockDestination = '28.967505747317997,-13.560605681682436';

        // Call the function
        final result = await provider.getPolylineAndDistanceAndDuration(
          mockOrigin,
          mockDestination,
        );

        // Assertions
        expect(result, isA<List<String>>());
        expect(result.length, equals(3));
        expect(result[0], isNotEmpty);
        expect(result[1], isNotEmpty);
        expect(result[2], isNotEmpty);
      },
    );

    test(
      'getPolylineAndDistanceAndDuration returns empty values for unreachable destination',
      () async {
        // Mock data
        const String mockOrigin = 'fake_address';
        const String mockUnreachableDestination = 'fake_address';

        // Call the function
        final result = await provider.getPolylineAndDistanceAndDuration(
          mockOrigin,
          mockUnreachableDestination,
        );

        // Assertions
        expect(result, isA<List<String>>());
        expect(result.length, equals(2));
        expect(result[0], isEmpty);
        expect(result[1], isEmpty);
      },
    );
  });
}
