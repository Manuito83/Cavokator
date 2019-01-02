import 'package:flutter/material.dart';
import 'weather.dart';

void main() => runApp(
      new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(primarySwatch: Colors.blueGrey),
        home: new WeatherPage(),
      ),
    );
