import 'package:flutter/material.dart';
import 'package:new_frontend/nav.dart';
import 'package:new_frontend/screens/Auth/login.dart';
import 'package:new_frontend/screens/Auth/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ingreedy',
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
