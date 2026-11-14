import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'weather_api.dart';
import 'weather_view.dart';

void main() => runApp(const BdWeatherApp());

class BdWeatherApp extends StatelessWidget {
  const BdWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BD Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff2857be),
        scaffoldBackgroundColor: const Color(0xfff0f4fa),
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  City city = cities.first;
  late Future<Map<String, dynamic>> request;

  @override
  void initState() {
    super.initState();
    request = fetchWeather(city);
  }

  void load(City nextCity) {
    setState(() {
      city = nextCity;
      request = fetchWeather(city);
      // FutureBuilder will read this result on the next frame.
      request.ignore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'BD Weather',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh forecast',
            onPressed: () => load(city),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<City>(
                      value: city,
                      isExpanded: true,
                      items: [
                        for (final option in cities)
                          DropdownMenuItem(
                            value: option,
                            child: Text(option.name),
                          ),
                      ],
                      onChanged: (nextCity) {
                        if (nextCity != null && nextCity != city) {
                          load(nextCity);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FutureBuilder<Map<String, dynamic>>(
                future: request,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_off_outlined),
                            const SizedBox(height: 8),
                            Text('Could not load weather for ${city.name}.'),
                            TextButton(
                              onPressed: () => load(city),
                              child: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return WeatherView(city: city.name, data: snapshot.data!);
                },
              ),
              Center(
                child: TextButton(
                  onPressed: () => launchUrl(
                    Uri.https('open-meteo.com'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Weather data by Open-Meteo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
