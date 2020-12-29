import 'screens/login_screen.dart';
import 'package:flutter/material.dart';
class App extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: 'Secure Notebook',
      home: Scaffold(
        body: LoginScreen(),
      ),
    );
  }
}