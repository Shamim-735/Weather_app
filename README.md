# BD Weather

A one-screen Flutter dashboard for current weather and a four-day forecast in five Bangladeshi cities. Open-Meteo supplies the temperature, weather condition, day/night status, humidity, wind speed, and forecast highs and lows. The app requests these values directly over HTTPS using the public REST API.

## Run in Android Studio

1. Extract the ZIP into a new folder. In Android Studio use **File → Open** and select the inner `bd_weather` folder with `pubspec.yaml`.
2. Use Flutter 3.35 / Dart 3.9 or a compatible newer SDK. In Android Studio's terminal run `flutter pub get`.
3. Start your Pixel emulator in **Tools → Device Manager** and turn on its Wi-Fi.
4. Open `lib/main.dart`, select your device, and press **Run**.

## 30-second explanation

> I selected Open-Meteo to build a weather dashboard. Each city has a latitude and longitude. Selecting Dhaka sends an HTTP GET request with Dhaka's coordinates. The API responds with JSON containing current conditions and a four-day forecast. I decode that into a Dart map. FutureBuilder displays loading, an error with retry, or the dashboard. The API's weather code selects an icon and condition label, and its day/night value controls the current-weather card.

## Walk through the code

| File | What to point at |
| --- | --- |
| `lib/weather_api.dart` | `City` holds the coordinates. `fetchWeather()` creates the URL, sends the GET request, checks HTTP 200, and decodes the JSON. |
| `lib/main.dart` | `main()` starts Flutter. `initState()` requests Chattogram once. `load()` updates the city and stores a new request in `setState()`. `FutureBuilder` reacts to that request. |
| `lib/weather_view.dart` | Reads the `current` and `daily` sections and shows them with Flutter widgets. The same index in each daily array gives that day's date, icon, high and low. |
| `pubspec.yaml` | Declares `http` for network requests and `url_launcher` for the attribution link. |
| `android/app/src/main/AndroidManifest.xml` | Declares Android internet permission. |



Run `flutter analyze` and `flutter test` to check the project. The widget test checks the GET request, loading, two different cities, an HTTP error and retry using controlled responses.

Weather data by [Open-Meteo](https://open-meteo.com) under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). The app rounds temperatures and maps weather codes to labels and icons. [Forecast API documentation](https://open-meteo.com/en/docs).
