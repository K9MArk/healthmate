import 'package:flutter/material.dart';

// Screens
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/dashboard.dart';
import 'screens/add_record.dart';
import 'screens/record_list.dart';
import 'screens/settings.dart';

void main() {
  runApp(HealthMateApp());
}

class HealthMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HealthMate",
      theme: ThemeData(primarySwatch: Colors.blue),

      // Starting screen of the app
      initialRoute: '/login',

      // Navigation routes
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/addRecord': (context) => AddRecordScreen(),
        '/recordList': (context) => RecordListScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
