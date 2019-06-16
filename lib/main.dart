import 'package:flutter/material.dart';
import 'drawer.dart';

void main() => runApp(new Cavokator());

class Cavokator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cavokator",
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        //brightness: Brightness.dark,
      ),
      home: DrawerPage(),
    );
  }
}
