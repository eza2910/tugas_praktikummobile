//main dart
import 'package:flutter/material.dart';
import 'screens/book_list_screen.dart';

void main() {
  runApp(const PraktikumMobileApp());
}

class PraktikumMobileApp extends StatelessWidget {
  const PraktikumMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Praktikum Mobile - Informatika Unkhair',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const Scaffold(body: BookListScreen()),
    );
  }
}
