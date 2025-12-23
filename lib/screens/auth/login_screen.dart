// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:libokul_frontend/services/apiclient.dart';
import 'package:libokul_frontend/services/storage_service.dart';
import 'package:libokul_frontend/screens/auth/register_screen.dart';
import 'package:libokul_frontend/screens/home/main_feed_screen.dart';
// import 'package:libokul_frontend/screens/home/main_feed_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // GİRİŞ İŞLEMİ MANTIĞI
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Gönderilecek veri
      final Map<String, dynamic> data = {
        'username': _usernameController.text,
        'password': _passwordController.text,
      };

      try {
        final response = await ApiClient().postData('/auth/login/', data);

        if (mounted) {
          if (response.statusCode == 200) {
            final body = json.decode(utf8.decode(response.bodyBytes));
            final token =
                body['token'] as String?; // Django'dan token bekliyoruz

            if (token != null) {
              // 1. Token'ı güvenli bir şekilde sakla
              await StorageService().saveToken(token);

              // 2. Ana Sayfaya yönlendir (Artık aktif!)
             if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainFeedScreen(
                      nickname: _usernameController
                          .text, // Login ekranındaki controller'dan alıyoruz
                      avatarIndex:
                          0, // Giriş yapana şimdilik varsayılan 0 veriyoruz
                    ),
                  ),
                );
              }
              // Başarı mesajı yerine yönlendirme yaptığımız için bunu kaldırıyoruz veya kısaltıyoruz.
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Giriş başarılı! Token kaydedildi.')),
              // );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hata: Token alınamadı.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else {
            // Hata: Backend'den gelen hata mesajını göster (örn: Parola yanlış)
            final errorBody = json.decode(utf8.decode(response.bodyBytes));
            String errorMessage = 'Kullanıcı adı veya parola hatalı.';

            if (errorBody is Map && errorBody.isNotEmpty) {
              // İlk hatayı yakala
              errorMessage = errorBody.values.first.toString();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Giriş Hatası: $errorMessage'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Bağlantı Hatası
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bağlantı Hatası: Sunucuya erişilemiyor.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B0B12),
              Color.fromARGB(255, 7, 38, 80),
              Color.fromARGB(255, 6, 51, 75),
            ],
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 80),

                // ✅ LİBOKUL Logo - Hiç dokunulmadı
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(color: Colors.blueGrey, width: 3),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/libogirisekranı.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'LİBOKUL',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            letterSpacing: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40.0),

                // Kullanıcı Adı Alanı - Koyu tema için stil eklendi
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(
                    color: Colors.white,
                  ), // Yazı rengi beyaz
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı veya E-posta',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.white70,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(
                      0.05,
                    ), // Çok hafif şeffaf arka plan
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Bu alan boş bırakılamaz.'
                      : null,
                ),
                const SizedBox(height: 20.0),

                // Parola Alanı - Koyu tema için stil eklendi
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Parola',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.white70,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Parola boş bırakılamaz.'
                      : null,
                ),
                const SizedBox(height: 40.0),

                // Giriş Yap Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color(
                        0xFF1A4D7A,
                      ), // Gradientin orta tonuna uygun mavi
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),

                // Kayıt Ol Yazısı
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Hesabınız yok mu? Hemen Kayıt Olun.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
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
