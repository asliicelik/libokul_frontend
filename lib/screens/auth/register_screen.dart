// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:libokul_frontend/services/apiclient.dart';
import 'package:video_player/video_player.dart';
import 'package:libokul_frontend/screens/onboarding_screen.dart'; // Import kontrol edildi

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final VideoPlayerController _squirrelController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();

    _squirrelController =
        VideoPlayerController.asset('assets/animations/liboelsallama.mp4')
          ..setLooping(true)
          ..setVolume(0.0)
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() => _videoReady = true);
            _squirrelController.play();
          });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _squirrelController.dispose();
    super.dispose();
  }

  // ✅ KAYIT İŞLEMİ MANTIĞI
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      try {
        final response = await ApiClient().postData('/auth/register/', data);

        if (!mounted) return;

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt başarılı! Bilgilerini tamamlayalım.'),
            ),
          );

          // ✅ HATA DÜZELTİLDİ: const kaldırıldı ve nickname parametresi eklendi
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OnboardingScreen(nickname: _usernameController.text),
            ),
          );
        } else {
          final errorBody = json.decode(utf8.decode(response.bodyBytes));
          String errorMessage = 'Bilinmeyen kayıt hatası.';
          if (errorBody is Map && errorBody.isNotEmpty) {
            errorMessage = errorBody.values.first.toString();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kayıt hatası: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bağlantı Hatası: Sunucuya erişilemiyor.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1B22),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIconColor: Colors.white70,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2B2D3A), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 51, 86, 115),
              width: 1.6,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0B12),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.home_rounded),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
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
            ),
            SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 16,
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 10),
                      const Text(
                        'Hoş Geldin!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _MascotIntro(
                        videoReady: _videoReady,
                        controller: _squirrelController,
                        message:
                            "Merhaba, ben Libo. Uygulamada sana rehberlik edeceğim.\nHadi bilgilerini dolduralım!",
                      ),
                      const SizedBox(height: 26),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'E-posta boş bırakılamaz.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Kullanıcı adı boş bırakılamaz.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Parola',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) =>
                            (value == null || value.isEmpty || value.length < 6)
                            ? 'Parola en az 6 karakter olmalıdır.'
                            : null,
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ElevatedButton(
                                onPressed: _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    152,
                                    57,
                                    198,
                                    240,
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 10,
                                  shadowColor: const Color.fromARGB(
                                    255,
                                    51,
                                    86,
                                    115,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  "Hadi Başlayalım!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              top: 10,
                              child: Container(
                                width: 34,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 16,
                              bottom: 12,
                              child: Container(
                                width: 26,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hesabın var mı? Geri dönüp giriş yapabilirsin.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MascotIntro extends StatelessWidget {
  final bool videoReady;
  final VideoPlayerController controller;
  final String message;

  const _MascotIntro({
    required this.videoReady,
    required this.controller,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          children: [
            _SpeechBubbleCard(
              text: message,
              textColor: const Color(0xFF2D2B55),
              bubbleColor: const Color(0xFFF5F6FA),
            ),
            const SizedBox(height: 16),
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 6),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 26,
                    offset: const Offset(0, 18),
                    color: Colors.black.withOpacity(0.35),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: videoReady
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: Align(
                          alignment: const Alignment(0, 0.25),
                          child: VideoPlayer(controller),
                        ),
                      ),
                    )
                  : const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeechBubbleCard extends StatelessWidget {
  final String text;
  final Color bubbleColor;
  final Color textColor;

  const _SpeechBubbleCard({
    required this.text,
    required this.bubbleColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, 12),
                color: Colors.black.withOpacity(0.25),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ),
        Positioned(
          bottom: -12,
          child: CustomPaint(
            size: const Size(26, 16),
            painter: _BubbleTailDownPainter(color: bubbleColor),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailDownPainter extends CustomPainter {
  final Color color;
  _BubbleTailDownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, 0)
      ..close();

    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paintFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
