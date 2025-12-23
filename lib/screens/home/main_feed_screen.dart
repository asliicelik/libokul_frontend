// lib/screens/home/main_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';

// --- ANA EKRAN (NAVIGATION) ---
class MainFeedScreen extends StatefulWidget {
  final String nickname;
  final int avatarIndex;

  const MainFeedScreen({
    super.key,
    required this.nickname,
    required this.avatarIndex,
  });

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Sayfaları burada tanımlıyoruz
    final List<Widget> pages = [
      const EducationTab(),
      const Center(
        child: Text("Keşfet", style: TextStyle(color: Colors.white)),
      ),
      ProfileTab(nickname: widget.nickname, avatarIndex: widget.avatarIndex),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF0B0B12),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Eğitim'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// --- EĞİTİM SEKMESİ ---
class EducationTab extends StatelessWidget {
  const EducationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Libokul",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            decoration: InputDecoration(
              hintText: "Ders veya konu ara...",
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Dersler",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildSubjectCard(
            context,
            "Matematik",
            Icons.functions,
            Colors.blueAccent,
          ),
          _buildSubjectCard(
            context,
            "Fizik",
            Icons.sensors,
            const Color(0xFFEA3E27),
          ),
          _buildSubjectCard(
            context,
            "Kimya",
            Icons.science,
            Colors.purpleAccent,
          ),
          _buildSubjectCard(context, "Biyoloji", Icons.eco, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailsScreen(
              subjectName: title,
              themeColor: accentColor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B22),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(-5, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

// --- DERS DETAY / VİDEO LİSTESİ EKRANI ---
class SubjectDetailsScreen extends StatelessWidget {
  final String subjectName;
  final Color themeColor;

  const SubjectDetailsScreen({
    super.key,
    required this.subjectName,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Statik Mock Veri (Backend bağlanana kadar)
    final List<Map<String, String>> mockVideos = [
      {
        "title": "$subjectName - Konu Anlatımı 1",
        "duration": "12:40",
        "url": "76979871",
      },
      {
        "title": "$subjectName - Soru Çözümü",
        "duration": "08:15",
        "url": "76979871",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      appBar: AppBar(
        title: Text(subjectName),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockVideos.length,
        itemBuilder: (context, index) {
          final video = mockVideos[index];
          return ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(vimeoId: video['url']!),
              ),
            ),
            leading: Icon(Icons.play_circle_fill, color: themeColor, size: 40),
            title: Text(
              video['title']!,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              video['duration']!,
              style: const TextStyle(color: Colors.white38),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
          );
        },
      ),
    );
  }
}

// --- VIMEO OYNATICI EKRANI ---
class VideoPlayerScreen extends StatefulWidget {
  final String vimeoId;
  const VideoPlayerScreen({super.key, required this.vimeoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final PodPlayerController controller;

  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.vimeo(widget.vimeoId),
    )..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(child: PodVideoPlayer(controller: controller)),
    );
  }
}

// --- PROFİL SEKMESİ ---
class ProfileTab extends StatelessWidget {
  final String nickname;
  final int avatarIndex;

  const ProfileTab({
    super.key,
    required this.nickname,
    required this.avatarIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 120),
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(
              'assets/images/avatar${avatarIndex + 1}.png',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nickname,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 70),
          _buildBadgeSection("Öğrenme Rozetleri", [
            _badge(
              Icons.sentiment_very_satisfied,
              "Hoş Geldin",
              "Hesap açıldı",
              true,
              Colors.green,
            ),
            _badge(
              Icons.play_circle,
              "İlk Videom",
              "Video izlendi",
              false,
              Colors.orange,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildBadgeSection(String title, List<Widget> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: badges,
          ),
        ),
      ],
    );
  }

  Widget _badge(
    IconData icon,
    String title,
    String desc,
    bool isUnlocked,
    Color color,
  ) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.3,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.5), width: 2),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
