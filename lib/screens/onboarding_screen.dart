// lib/screens/auth/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:libokul_frontend/screens/home/main_feed_screen.dart';
import 'package:libokul_frontend/screens/auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final String nickname;

  const OnboardingScreen({super.key, required this.nickname});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;
  int? _selectedAvatarIndex; // Seçilen görselin numarası

  late VideoPlayerController _liboController;

  // Seçim Değişkenleri
  DateTime? _selectedDate;
  String? _selectedGrade;
  String? _selectedGoal;

  final List<String> _grades = [
    "9. Sınıf",
    "10. Sınıf",
    "11. Sınıf",
    "12. Sınıf",
    "Mezun",
  ];
  final List<String> _goals = ["YKS", "KPSS", "Okula Destek"];

  @override
  void initState() {
    super.initState();
    _liboController =
        VideoPlayerController.asset('assets/animations/libosinifta.mp4')
          ..initialize().then((_) {
            setState(() {});
            _liboController.setLooping(true);
            _liboController.play();
          });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _liboController.dispose();
    super.dispose();
  }

  void _nextPage() {
    String? errorMessage;

    // Hangi sayfadaysak o sayfanın verisini kontrol et
    if (_currentPage == 1 && _selectedDate == null) {
      errorMessage = "Lütfen doğum tarihinizi seçin.";
    } else if (_currentPage == 2 && _selectedGrade == null) {
      errorMessage = "Lütfen sınıfınızı seçin.";
    } else if (_currentPage == 3 && _selectedGoal == null) {
      errorMessage = "Lütfen hedefinizi seçin.";
    } else if (_currentPage == 4 && _selectedAvatarIndex == null) {
      errorMessage = "Lütfen bir profil karakteri seçin.";
    }

    // Eğer hata varsa SnackBar göster ve ilerleme
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Hata yoksa sonraki sayfaya geç
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _saveOnboardingData(); // Son sayfada verileri kaydet
    }
  }
  // Verileri backend'e göndermek için kullanacağımız fonksiyonun taslağı
  Future<void> _saveOnboardingData() async {
    // Kullanıcının seçtiği verileri bir araya toplayalım
    final onboardingData = {
      'nickname': widget.nickname,
      'birthday': _selectedDate?.toIso8601String(),
      'grade': _selectedGrade,
      'goal': _selectedGoal,
      'avatar_index': _selectedAvatarIndex,
    };
      if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainFeedScreen(
            nickname: widget.nickname, // Onboarding'e gelen nick
            avatarIndex: _selectedAvatarIndex ?? 0, // Seçilen avatar
          ),
        ),
      );
    }
    print("Backend'e gönderilecek veriler: $onboardingData");

    // Şimdilik sadece ana akışa yönlendirelim
    iif(mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainFeedScreen(
            nickname: widget.nickname, // Onboarding'e gelen nick
            avatarIndex:
                _selectedAvatarIndex ?? 0, // Kullanıcının seçtiği avatar
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0B12), Color(0xFF072650), Color(0xFF06334B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Üst Kısım: Progress Bar ve Libo Animasyonu
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_currentPage + 1) / _totalPages,
                          backgroundColor: Colors.white10,
                          color: const Color(0xFF39C6F0),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _liboController.value.isInitialized
                          ? VideoPlayer(_liboController)
                          : const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ),
              ),

              // 2. Sayfalar
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildNicknameStep(),
                    _buildBirthdayStep(),
                    _buildGradeStep(),
                    _buildGoalStep(),
                    _buildProfilePicStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ADIM TASARIMLARI ---

  Widget _buildNicknameStep() {
    return _buildStepLayout(
      title: "Hoş geldin!",
      subtitle: "Kayıt olduğun nickname ile devam edelim mi?",
      content: Column(
        children: [
          const Icon(Icons.verified_user, color: Color(0xFF39C6F0), size: 80),
          const SizedBox(height: 20),
          Text(
            "@${widget.nickname}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // lib/screens/auth/onboarding_screen.dart içindeki ilgili metod

  Widget _buildBirthdayStep() {
    return _buildStepLayout(
      title: "Doğum Günün Ne Zaman?",
      subtitle:
          "Sana özel içerikler ve hatırlatıcılar sunabilmemiz için önemli.",
      content: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2010), 
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF39C6F0), // Takvimdeki ana renk
                    onPrimary: Colors.black,
                    surface: Color(0xFF0B0B12),
                    onSurface: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              _selectedDate = picked;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate == null
                    ? "Tarih Seçmek İçin Dokun"
                    : "${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const Icon(Icons.calendar_month, color: Color(0xFF39C6F0)),
            ],
          ),
        ),
      ),
    );
  }

  // Sınıf seçimi için kutucuk tasarımı
  Widget _buildGradeStep() {
    return _buildStepLayout(
      title: "Kaçıncı Sınıfsın?",
      subtitle: "Akışını senin sınıf seviyene göre düzenleyeceğiz.",
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _grades.map((grade) {
          bool isSelected = _selectedGrade == grade;
          return InkWell(
            onTap: () => setState(() => _selectedGrade = grade),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF39C6F0)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white10,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF39C6F0).withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: Text(
                grade,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalStep() {
    return _buildStepLayout(
      title: "Hedefin Ne?",
      subtitle: "Hangi sınava yönelik çalışıyorsun?",
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _goals
            .map(
              (goal) => _buildSelectableBox(
                goal,
                _selectedGoal,
                (val) => setState(() => _selectedGoal = val),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildProfilePicStep() {
    return _buildStepLayout(
      title: "Profil Karakterini Seç",
      subtitle: "Seni en iyi yansıtan Libo karakterini seçebilirsin!",
      content: SizedBox(
        height: 250, 
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 9, 
          itemBuilder: (context, index) {
            bool isSelected = _selectedAvatarIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatarIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF39C6F0)
                        : Colors.white24,
                    width: isSelected ? 4 : 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF39C6F0).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatar${index + 1}.png',
                    fit: BoxFit.cover,
                    // Görsel henüz yüklenmemişse bir placeholder göster
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, color: Colors.white38),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- YARDIMCI METODLAR ---

  Widget _buildStepLayout({
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 50),
          content,
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A4D7A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Devam Et",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableBox(
    String label,
    String? selectedVal,
    Function(String) onSelect,
  ) {
    bool isSelected = label == selectedVal;
    return InkWell(
      onTap: () => onSelect(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF39C6F0)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
