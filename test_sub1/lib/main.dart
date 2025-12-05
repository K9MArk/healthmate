import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';
import 'home.dart';

void main() {
  runApp(const SimpleAuthApp());
}

class SimpleAuthApp extends StatelessWidget {
  const SimpleAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Auth App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: false,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
