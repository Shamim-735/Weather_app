import 'dart:convert';

import 'package:bd_weather/main.dart';
import 'package:bd_weather/weather_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('shows forecast, switches cities, and retries a failed refresh', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final requests = <String?>[];
    await http.runWithClient(
      () async {
        await tester.pumpWidget(const BdWeatherApp());
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.text('29°C'), findsOneWidget);
        expect(find.text('4-day forecast'), findsOneWidget);

        await tester.tap(find.byType(DropdownButton<City>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dhaka').last);
        await tester.pumpAndSettle();
        expect(find.text('25°C'), findsOneWidget);

        await tester.tap(find.byTooltip('Refresh forecast'));
        await tester.pumpAndSettle();
        expect(find.text('Could not load weather for Dhaka.'), findsOneWidget);

        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(find.text('25°C'), findsOneWidget);
        expect(requests, ['22.3569', '23.8103', '23.8103', '23.8103']);
      },
      () => MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.host, 'api.open-meteo.com');
        expect(request.url.path, '/v1/forecast');
        expect(request.url.queryParameters['forecast_days'], '4');
        final latitude = request.url.queryParameters['latitude'];
        requests.add(latitude);
        if (requests.length == 3) return http.Response('Unavailable', 503);
        return http.Response(
          jsonEncode({
            'current': {
              'time': '2026-11-13T15:45',
              'temperature_2m': latitude == '22.3569' ? 29 : 25,
              'relative_humidity_2m': 51,
              'wind_speed_10m': 6.8,
              'weather_code': 0,
              'is_day': 1,
            },
            'daily': {
              'time': ['2026-11-13', '2026-11-14', '2026-11-15', '2026-11-16'],
              'weather_code': [0, 1, 3, 61],
              'temperature_2m_max': [29, 28, 27, 26],
              'temperature_2m_min': [20, 21, 21, 19],
            },
          }),
          200,
        );
      }),
    );
  });
}
