// lib/main.dart
import 'package:flutter/material.dart';
// Ana ekran dosyasını import et
import 'package:libokul_frontend/screens/home_screen.dart';

void main() {
  runApp(const LibokulApp());
}

class LibokulApp extends StatelessWidget {
  const LibokulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Libokul',
      theme: ThemeData(primarySwatch: Colors.amber),

      home: const HomeScreen(),
    );
  }
}
