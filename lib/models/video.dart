// lib/models/video.dart

class Video {
  final int id;
  final String title;
  final String description;
  final String videoUrl; // Osman'ın sunucusundan gelen video adresi
  final String uploader; 

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.uploader,
  });

  // JSON'dan Dart objesine dönüştürme (Fabrika Yapılandırıcısı)
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      // Backend'deki anahtar adlarının tam olarak eşleştiğinden emin olun (Osman'ın DB modeline göre)
      videoUrl: json['video_url'] as String, 
      uploader: json['uploader'] as String? ?? 'Bilinmiyor', // Yükleyici yoksa varsayılan atama
    );
  }
}