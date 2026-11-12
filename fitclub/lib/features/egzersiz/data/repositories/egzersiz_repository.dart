import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../core/network/dio_client.dart';
import '../models/egzersiz_model.dart';

class EgzersizRepository {
  final DioClient _dioClient = DioClient();

  Future<List<EgzersizModel>> egzersizleriGetir() async {
    try {
      // Wger çöpe gitti. 800+ hareket içeren açık kaynaklı Free Exercise DB'yi kullanıyoruz.
      // 100% Ücretsiz, Key istemez, çökmez.
      final response = await _dioClient.dio.get('https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json');

      if (response.statusCode == 200) {
        // GitHub bazen JSON'ı düz metin (String) olarak yollayabilir, garantiye alıp dönüştürüyoruz.
        final veri = response.data is String ? jsonDecode(response.data) : response.data;
        
        // Bu API verileri direkt devasa bir liste olarak döndürüyor
        final List<dynamic> hamVeriListesi = veri;
        
        // 800 hareketin hepsini yükletip telefonu kasmamak için ilk 100 tanesini alıyoruz
        final List<dynamic> ilk100Hareket = hamVeriListesi.take(100).toList();

        return ilk100Hareket.map((json) => EgzersizModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("🚨 Ağ hatası: ${e.message}");
      return []; 
    } catch (e) {
      print("🚨 Beklenmeyen hata: $e");
      return [];
    }
  }
}