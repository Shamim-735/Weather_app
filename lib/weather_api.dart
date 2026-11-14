import 'dart:convert';

import 'package:http/http.dart' as http;

class City {
  const City(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;
}

const cities = [
  City('Chattogram', 22.3569, 91.7832),
  City('Dhaka', 23.8103, 90.4125),
  City('Sylhet', 24.8949, 91.8687),
  City('Rajshahi', 24.3745, 88.6042),
  City('Khulna', 22.8456, 89.5403),
];

Future<Map<String, dynamic>> fetchWeather(City city) async {
  final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': city.latitude.toString(),
    'longitude': city.longitude.toString(),
    'current':
        'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,is_day',
    'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
    'timezone': 'Asia/Dhaka',
    'forecast_days': '4',
  });

  final response = await http.get(url).timeout(const Duration(seconds: 15));
  if (response.statusCode != 200) {
    throw Exception('Weather request failed (HTTP ${response.statusCode})');
  }
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final current = data['current'] as Map<String, dynamic>;
  final daily = data['daily'] as Map<String, dynamic>;
  final dates = daily['time'] as List<dynamic>;
  if (current['time'] is! String ||
      dates.length != 4 ||
      [
        'weather_code',
        'temperature_2m_max',
        'temperature_2m_min',
      ].any((key) => (daily[key] as List<dynamic>).length != dates.length)) {
    throw const FormatException('Incomplete weather response');
  }
  return data;
}
