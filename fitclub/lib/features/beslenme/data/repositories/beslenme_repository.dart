import 'package:dio/dio.dart';
// Core katmanındaki Dio yöneticimizi ve az önce yazdığımız modeli çağırıyoruz
import '../../../../core/network/dio_client.dart';
import '../models/besin_model.dart';

class BeslenmeRepository {
  final DioClient _dioClient = DioClient();

  // Kullanıcının arama çubuğuna yazdığı kelimeyi (sorgu) parametre olarak alıyoruz
  Future<List<BesinModel>> besinAra(String sorgu) async {
    try {
      // Open Food Facts API'sine arama isteği atıyoruz.
      // Bu API tamamen ücretsiz ve anahtarsız olduğu için header/token dertlerimiz yok.
      final response = await _dioClient.dio.get(
        'https://world.openfoodfacts.org/cgi/search.pl',
        queryParameters: {
          'search_terms': sorgu, // Kullanıcının aradığı kelime (Örn: "Yulaf")
          'search_simple': 1,
          'action': 'process',
          'json': 1, // Bize veriyi düzgün, parçalanabilir formatta (JSON) gönder diyoruz
          'page_size': 20, // Tek seferde en fazla 20 sonuç getirsin ki uygulama kasmasın
        },
      );

      // İstek başarılı olduysa (200 OK)
      if (response.statusCode == 200) {
        // Open Food Facts, verileri 'products' (ürünler) adında bir liste içinde gönderir.
        final List<dynamic> hamVeriListesi = response.data['products'] ?? [];

        // Egzersiz modülünde yaptığımız gibi, ham JSON verisini kendi modelimize dönüştürüp liste yapıyoruz
        return hamVeriListesi.map((json) => BesinModel.fromJson(json)).toList();
      } else {
        // Sunucu hata verirse boş liste döndürüyoruz
        return [];
      }
    } catch (e) {
      // İnternet koparsa veya API çökerse hatayı yakalıyoruz
      print("🚨 Besin ararken ağ hatası oluştu: $e");
      return []; 
    }
  }
}