// lib/services/apiclient.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// StorageService artık import edilmiş durumda
import 'package:libokul_frontend/services/storage_service.dart';
// Yeni eklenen Video modelini de import etmeliyiz
import 'package:libokul_frontend/models/video.dart';

// class ApiClient {
//   static const String _baseUrl = 'http://192.168.1.189:8000/api';

//   static final ApiClient _instance = ApiClient._internal();
//   factory ApiClient() => _instance;
//   ApiClient._internal();

//   // 5. POST İsteği Metodu (POST metodu aynı kalıyor)
//   Future<http.Response> postData(
//     String endpoint,
//     Map<String, dynamic> data,
//   ) async {

//     final url = Uri.parse('$_baseUrl$endpoint');

//     final headers = {'Content-Type': 'application/json'};

//     try {
//       final response = await http.post(
//         url,
//         headers: headers,
//         body: json.encode(data),
//       );

//       return response;
//     } catch (e) {
//       throw Exception(
//         'API İsteği Başarısız (POST): Sunucuya erişilemiyor veya ağ hatası. Detay: $e',
//       );
//     }
//   }

//   // 6. GET İsteği Metodu (Güncellendi: Token okuma mantığı eklendi)
//   Future<http.Response> getData(String endpoint) async {
//     final url = Uri.parse('$_baseUrl$endpoint');

//     // StorageService kullanarak saklanan tokenı oku
//     final token = await StorageService().readToken();

//     final headers = {
//       'Content-Type': 'application/json',
//       // Token varsa Authorization başlığını ekle
//       if (token != null) 'Authorization': 'Token $token',
//     };

//     try {
//       final response = await http.get(url, headers: headers);
//       return response;
//     } catch (e) {
//       throw Exception(
//         'API İsteği Başarısız (GET): Sunucuya erişilemiyor veya ağ hatası. Detay: $e',
//       );
//     }
//   }

//   // 7. Video Listesini Çekme Metodu (Yeni Eklendi)
//   Future<List<Video>> fetchVideos() async {
//     // Osman'ın onaylı videolar için belirlediği endpoint
//     const endpoint = '/content/videos/';

//     // getData metodunu kullanarak yetkilendirilmiş GET isteğini gönder
//     final response = await getData(endpoint);

//     if (response.statusCode == 200) {
//       // Backend'den gelen JSON listesini al (UTF-8 decode, Türkçe karakterler için)
//       final List<dynamic> jsonList = json.decode(
//         utf8.decode(response.bodyBytes),
//       );

//       // Her bir JSON elemanını, Video modelinin fromJson metoduyla Dart objesine dönüştür.
//       return jsonList.map((json) => Video.fromJson(json)).toList();
//     } else if (response.statusCode == 401) {
//       // Yetkilendirme hatası (Token süresi dolmuş veya geçersiz)
//       throw Exception('Yetkisiz Erişim. Lütfen tekrar giriş yapın.');
//     } else {
//       // Diğer sunucu hataları
//       throw Exception(
//         'Video listesi çekilemedi: Hata kodu ${response.statusCode}',
//       );
//     }
//   }
// }
class ApiClient {
  static const String _baseUrl = 'http://192.168.1.189:8000/api';

  // ✅ Tek tuş: backend bypass
  static const bool DEV_OFFLINE_MODE = true;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<http.Response> postData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    // ✅ DEV: her POST'u başarılı say
    if (DEV_OFFLINE_MODE) {
      // register/login gibi isteklerde 201/200 dönmek yeterli
      return http.Response(
        json.encode({
          "dev": true,
          "endpoint": endpoint,
          "token": "token9",
          "message": "DEV_OFFLINE_MODE: POST bypassed",
        }),
        endpoint.contains('register') ? 201 : 200,
        headers: {"content-type": "application/json; charset=utf-8"},
      );
    }

    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return response;
    } catch (e) {
      throw Exception(
        'API İsteği Başarısız (POST): Sunucuya erişilemiyor veya ağ hatası. Detay: $e',
      );
    }
  }

  Future<http.Response> getData(String endpoint) async {
    // ✅ DEV: endpoint'e göre sahte data dön
    if (DEV_OFFLINE_MODE) {
      // Video listesi endpoint'i için mock response
      if (endpoint == '/content/videos/' ||
          endpoint.contains('/content/videos')) {
        // ⚠️ İstersen burayı kendi Video model alanlarına göre düzenle
        final mock = [
          {
            "id": 1,
            "title": "Deneme Video 1",
            "description": "DEV mod: UI test videosu",
            "video_url": "https://example.com/video1.mp4",
            "thumbnail_url": "https://example.com/thumb1.jpg",
          },
          {
            "id": 2,
            "title": "Deneme Video 2",
            "description": "DEV mod: quiz ekranına geçiş testi",
            "video_url": "https://example.com/video2.mp4",
            "thumbnail_url": "https://example.com/thumb2.jpg",
          },
        ];

        return http.Response(
          json.encode(mock),
          200,
          headers: {"content-type": "application/json; charset=utf-8"},
        );
      }

      // Diğer GET'ler için genel mock
      return http.Response(
        json.encode({
          "dev": true,
          "endpoint": endpoint,
          "message": "DEV_OFFLINE_MODE: GET bypassed",
        }),
        200,
        headers: {"content-type": "application/json; charset=utf-8"},
      );
    }

    final url = Uri.parse('$_baseUrl$endpoint');

    final token = await StorageService().readToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      return response;
    } catch (e) {
      throw Exception(
        'API İsteği Başarısız (GET): Sunucuya erişilemiyor veya ağ hatası. Detay: $e',
      );
    }
  }

  Future<List<Video>> fetchVideos() async {
    const endpoint = '/content/videos/';
    final response = await getData(endpoint);

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));

      // ✅ Backend bazen List, bazen {results:[...]} döndürebilir.
      List<dynamic> jsonList;
      if (decoded is List) {
        jsonList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        jsonList =
            (decoded['results'] ?? decoded['data'] ?? decoded['videos'] ?? [])
                as List<dynamic>;
      } else {
        jsonList = [];
      }

      return jsonList.map((j) => Video.fromJson(j)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Yetkisiz Erişim. Lütfen tekrar giriş yapın.');
    } else {
      throw Exception(
        'Video listesi çekilemedi: Hata kodu ${response.statusCode}',
      );
    }
  }
}
