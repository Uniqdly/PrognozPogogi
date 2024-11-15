import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Прогноз погоды',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = 'fa730a3949a18a9bbf3da52d69e0e9d2';
  String selectedCity = 'Москва';
  final List<String> cities = ['Лондон', 'Нью-Йорк', 'Париж', 'Токио', 'Москва'];
  Map<String, dynamic>? weatherData;
  List<dynamic> forecastData = [];

  @override
  void initState() {
    super.initState();
    fetchWeather(selectedCity);
    fetchForecast(selectedCity);
  }

  Future<void> fetchWeather(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=ru');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body);
      });
    } else {
      setState(() {
        weatherData = null;
      });
      print('Не удалось получить данные о погоде: ${response.body}');
    }
  }

  Future<void> fetchForecast(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=ru');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        forecastData = json.decode(response.body)['list'];
      });
    } else {
      setState(() {
        forecastData = [];
      });
      print('Не удалось получить данные о прогнозе погоды: ${response.body}');
    }
  }

  Widget _buildWeatherInfo() {
    if (weatherData == null) {
      return Center(child: Text("Нет данных о погоде."));
    }

    final temp = weatherData!['main']['temp'];
    final pressure = weatherData!['main']['pressure'];
    final humidity = weatherData!['main']['humidity'];
    final windSpeed = weatherData!['wind']['speed'];
    final weatherDescription = weatherData!['weather'][0]['description'];
    final iconCode = weatherData!['weather'][0]['icon'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network('http://openweathermap.org/img/w/$iconCode.png'),
        Text(
          '$temp°C',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        Text(
          weatherDescription.toString().toUpperCase(),
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 10),
        Text('Давление: $pressure гПа'),
        Text('Влажность: $humidity%'),
        Text('Скорость ветра: $windSpeed м/с'),
      ],
    );
  }

Widget _buildForecast() {
  if (forecastData.isEmpty) {
    return Center(child: Text("Нет данных о прогнозе погоды."));
  }

  return ListView.builder(
    // Берём только каждый 4-й элемент (т.е., с интервалом 12 часов)
    itemCount: (forecastData.length / 4).ceil(),
    itemBuilder: (context, index) {
      final forecast = forecastData[index * 4];
      final dateTime = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      final temp = forecast['main']['temp'];
      final description = forecast['weather'][0]['description'];
      final iconCode = forecast['weather'][0]['icon'];

      return ListTile(
        leading: Image.network('http://openweathermap.org/img/w/$iconCode.png'),
        title: Text(
          '${dateTime.day}/${dateTime.month} ${dateTime.hour}:00',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description.toString().toUpperCase()),
        trailing: Text('$temp°C'),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Погода в $selectedCity'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedCity,
              items: cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCity = value;
                  });
                  fetchWeather(value);
                  fetchForecast(value);
                }
              },
            ),
            Expanded(
              child: _buildWeatherInfo(),
            ),
            SizedBox(height: 20),
            Text(
              'Прогноз на ближайшие дни',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _buildForecast(),
            ),
          ],
        ),
      ),
    );
  }
}
