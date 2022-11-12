import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Weather app';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  static String region = "moscow";
  bool showWidget = false;

  static String getRegion() {
    return region;
  }

  @override
  void initState() {
    super.initState();
    _calculation = loadWeather();
  }

  late Future<CurrentWeather> _calculation;

  Future<CurrentWeather> loadWeather() async {
    var regionName = getRegion();
    print("get region: $regionName");
    var response = await http.get(Uri.parse('http://api.worldweatheronline.com/premium/v1/weather.ashx?key=ab445736b43d49fd82f141119221111&q=$regionName&format=json'));
    if (response.statusCode == 200) {
      return CurrentWeather.fromJson(jsonDecode(response.body));
    } else {
      print("code ${response.statusCode}");
      throw Exception('Failed to load weather data');
    }
  }

  // Future<CurrentWeather> _calculation = Future<CurrentWeather>.delayed(
  //   const Duration(milliseconds: 2000), () async {
  //         var regionName = getRegion();
  //         print("get region: $regionName");
  //         var response = await http.get(Uri.parse('http://api.worldweatheronline.com/premium/v1/weather.ashx?key=ab445736b43d49fd82f141119221111&q=$regionName&format=json'));
  //         if (response.statusCode == 200) {
  //           return CurrentWeather.fromJson(jsonDecode(response.body));
  //         } else {
  //           print("code ${response.statusCode}");
  //           throw Exception('Failed to load weather data');
  //         }
  //       }
  // );

  final TextEditingController _controller = TextEditingController();

  void sendRegion() {
    if (_controller.text.isNotEmpty) {
      region = _controller.text;
      _calculation = loadWeather();
      print("set region: $region");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Weather app'),
        ),
        body: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Material(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter a message',
                        suffixIcon: IconButton(
                          onPressed: _controller.clear,
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
                ],
              ),


                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showWidget = true;
                      sendRegion();
                    });
                  },
                  child: Text("OK"),
              ),

              showWidget
              ? FutureBuilder<CurrentWeather>(
                future: _calculation,
                builder: (BuildContext context,
                    AsyncSnapshot<CurrentWeather> snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData) {
                    children = <Widget>[
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                            Text("Температура: ${snapshot.data!.getTemp()}°C"),
                            Text("Скорость ветра: ${snapshot.data!.getWindSpeed()}км/ч"),
                            Text("Шанс дождя: ${snapshot.data!.getChanceRain()}%"),
                            Text("Облачность: ${snapshot.data!.getCloudCover()}%"),
                            Text("Влажность: ${snapshot.data!.getHumidity()}%"),
                            Text("Атмосферное давление: ${snapshot.data!.getPressure()} миллибар"),
                          ],
                        ),
                      ),
                    ];
                  } else if (snapshot.hasError) {
                    children = <Widget>[
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    ];
                  } else {
                    children = const <Widget>[
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Awaiting result...'),
                      ),
                    ];
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children,
                    ),
                  );
                },
              ) : Container(),
            ]
        ),
    );
  }
}

class CurrentWeather {
  int temp_C;
  int windspeedKmph;
  int chanceOfRain;
  int cloudCover;
  int humidity;
  int pressure;

  CurrentWeather({
    required this.temp_C,
    required this.windspeedKmph,
    required this.chanceOfRain,
    required this.cloudCover,
    required this.humidity,
    required this.pressure
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    print(json['data']['current_condition'][0]);
    print(json['data']);
    return CurrentWeather(
        temp_C: int.parse(json['data']['current_condition'][0]['temp_C']),
        windspeedKmph: int.parse(json['data']['current_condition'][0]['windspeedKmph']),
        chanceOfRain: int.parse(json['data']['weather'][0]['hourly'][0]['chanceofrain']),
        cloudCover: int.parse(json['data']['current_condition'][0]['cloudcover']),
        humidity: int.parse(json['data']['current_condition'][0]['humidity']),
        pressure: int.parse(json['data']['current_condition'][0]['pressure'])
    );
  }

  int getTemp() {
    return temp_C;
  }

  int getWindSpeed() {
    return windspeedKmph;
  }

  int getChanceRain() {
    return chanceOfRain;
  }

  int getCloudCover() {
    return cloudCover;
  }

  int getHumidity() {
    return humidity;
  }

  int getPressure() {
    return pressure;
  }
}