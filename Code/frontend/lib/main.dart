import 'package:flutter/material.dart';
import 'package:frontend/nav.dart';
import 'package:frontend/screens/Auth/login.dart';
import 'package:frontend/screens/Auth/register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginPage(),
        '/register': (_) => RegisterPage(),
        '/navbar': (_) => const NavBar(),
      },
    );
  }
}
