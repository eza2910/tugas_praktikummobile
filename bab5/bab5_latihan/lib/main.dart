import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';
import 'screen/login_screen.dart';
import 'screen/home_screen.dart';
import 'http_override.dart';
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides(); // FIX SSL ERROR
  runApp(HMTINewsApp());
}

class HMTINewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HMTI News',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(token: ''),
      },
    );
  }
}
