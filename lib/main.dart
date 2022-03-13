import 'package:flutter/material.dart';
import 'package:todo/pages/HomePage.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF0b132b),
        textTheme: TextTheme(
          subtitle1: TextStyle(color: Colors.white),
          headline6: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
        cardColor: Color(0xFF1c2541),
      ),
      home: HomePage(),
    );
  }
}
