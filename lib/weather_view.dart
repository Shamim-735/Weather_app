import 'package:flutter/material.dart';

class WeatherView extends StatelessWidget {
  const WeatherView({super.key, required this.city, required this.data});

  final String city;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;
    final dates = daily['time'] as List<dynamic>;
    final isDay = current['is_day'] == 1;
    final (label, icon) = weatherCondition(current['weather_code'], isDay);
    final temperature = current['temperature_2m'] as num?;
    final humidity = current['relative_humidity_2m'];
    final wind = current['wind_speed_10m'];
    final localizations = MaterialLocalizations.of(context);
    final clock = (current['time'] as String).split('T').last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDay
                  ? const [Color(0xff122f75), Color(0xff2857be)]
                  : const [Color(0xff111e45), Color(0xff343e88)],
            ),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white, fontSize: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Conditions at $clock · Bangladesh time',
                  style: const TextStyle(
                    color: Color(0xffdce8ff),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              temperature == null
                                  ? '—'
                                  : '${degrees(temperature)}C',
                              style: const TextStyle(
                                fontSize: 54,
                                height: 1.1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(label),
                        ],
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x26ffffff),
                      ),
                      child: Icon(
                        icon,
                        size: 44,
                        color: const Color(0xffffdf97),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    metric(
                      Icons.water_drop_outlined,
                      humidity == null ? 'Humidity —' : '$humidity% humidity',
                    ),
                    metric(Icons.air, wind == null ? 'Wind —' : '$wind km/h'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '4-day forecast',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          margin: EdgeInsets.zero,
          elevation: 0,
          child: Column(
            children: [
              for (var index = 0; index < dates.length; index++) ...[
                if (index > 0)
                  const Divider(height: 1, indent: 14, endIndent: 14),
                forecastRow(
                  day: index == 0
                      ? 'Today'
                      : localizations.formatShortMonthDay(
                          DateTime.parse('${dates[index]}T00:00:00Z'),
                        ),
                  code: daily['weather_code'][index],
                  high: daily['temperature_2m_max'][index],
                  low: daily['temperature_2m_min'][index],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Widget forecastRow({
  required String day,
  required int? code,
  required num? high,
  required num? low,
}) {
  final (label, icon) = weatherCondition(code);
  return ListTile(
    dense: true,
    leading: Icon(icon, color: const Color(0xff2857be)),
    title: Text(day),
    subtitle: Text(label),
    trailing: Text(
      'H ${degrees(high)}   L ${degrees(low)}',
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

Widget metric(IconData icon, String value) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0x22ffffff),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Wrap(
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        Text(value),
      ],
    ),
  );
}

String degrees(num? value) => value == null ? '—' : '${value.round()}°';

(String, IconData) weatherCondition(int? code, [bool isDay = true]) {
  return switch (code) {
    0 => (
      'Clear sky',
      isDay ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
    ),
    1 || 2 => ('Partly cloudy', Icons.wb_cloudy_outlined),
    3 => ('Overcast', Icons.cloud_outlined),
    45 || 48 => ('Fog', Icons.foggy),
    51 || 53 || 55 => ('Drizzle', Icons.grain),
    56 || 57 || 66 || 67 => ('Freezing precipitation', Icons.ac_unit),
    61 || 63 || 65 || 80 || 81 || 82 => ('Rain', Icons.water_drop_outlined),
    71 || 73 || 75 || 77 || 85 || 86 => ('Snow', Icons.ac_unit),
    95 || 96 || 99 => ('Thunderstorm', Icons.thunderstorm_outlined),
    _ => ('Unknown conditions', Icons.help_outline),
  };
}
