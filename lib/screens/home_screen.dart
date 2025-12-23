// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:libokul_frontend/screens/auth/login_screen.dart';
import 'package:libokul_frontend/screens/auth/register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B0B12),
              Color.fromARGB(255, 3, 26, 56),
              Color.fromARGB(255, 6, 51, 75),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // LİBOKUL Logo
                Image.asset(
                  'assets/images/liboanalogo.png',
                  height: 300,
                  width: 500,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'LİBOKUL',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        letterSpacing: 2,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 5.0),

                // Alt başlık
                const Text(
                  'Kaydır, öğren, geliş.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 80.0),

                // Hadi başlayalım! (Register)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(152, 57, 198, 240),
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: const Color.fromARGB(255, 51, 86, 115),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Hadi başlayalım!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),

                // Zaten bir hesabım var (Login)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Zaten bir hesabım var',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 51, 86, 115),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
