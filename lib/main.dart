import 'package:flutter/material.dart';
import 'HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(const [
        {'label': 'Constant Text 1', 'hint': 'Enter input for text 1'},
        {'label': 'Constant Text 2', 'hint': 'Enter input for text 2'},
        // Add more constant text and hints as needed
      ]),
    );
  }
}
