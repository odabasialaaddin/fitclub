import 'package:hive_flutter/hive_flutter.dart';
import '../models/antrenman_model.dart';

// Veri kaynağımızın yapması gereken işlerin listesi (Interface)
abstract class AntrenmanLocalDataSource {
  // --- 1. GEÇMİŞ ANTRENMAN İŞLEMLERİ ---
  Future<void> antrenmanKaydet(AntrenmanKaydiModel kayit);
  Future<List<AntrenmanKaydiModel>> tumGecmisKayitlariGetir();
  Future<List<AntrenmanKaydiModel>> hareketeGoreGecmisGetir(String hareketId);
  Future<void> antrenmanSil(String id);

  // --- 2. YENİ: HAZIR ŞABLON (RUTİN) İŞLEMLERİ ---
  Future<void> rutinKaydet(AntrenmanRutiniModel rutin);
  Future<List<AntrenmanRutiniModel>> tumRutinleriGetir();
  Future<void> rutinSil(String id);
}

// İşleri gerçekten yapan asıl işçi sınıfımız (Implementation)
class AntrenmanLocalDataSourceImpl implements AntrenmanLocalDataSource {
  // İki farklı veritabanı kutumuz (Tablomuz) var
  final String _gecmisBoxName = 'antrenman_gecmisi_box';
  final String _rutinBoxName = 'antrenman_rutinleri_box'; // YENİ KUTU

  // ========================================================
  // 1. GEÇMİŞ ANTRENMAN İŞLEMLERİ (Mevcut kodlar, dokunulmadı)
  // ========================================================
  @override
  Future<void> antrenmanKaydet(AntrenmanKaydiModel kayit) async {
    final box = await Hive.openBox(_gecmisBoxName);
    await box.put(kayit.id, kayit.toMap());
  }

  @override
  Future<List<AntrenmanKaydiModel>> tumGecmisKayitlariGetir() async {
    final box = await Hive.openBox(_gecmisBoxName);
    final liste = <AntrenmanKaydiModel>[];
    
    for (var key in box.keys) {
      final map = box.get(key);
      if (map != null) {
        liste.add(AntrenmanKaydiModel.fromMap(map));
      }
    }
    
    // Antrenmanları tarihe göre yeniden eskiye sıralıyoruz
    liste.sort((a, b) => b.tarih.compareTo(a.tarih));
    return liste;
  }

  @override
  Future<List<AntrenmanKaydiModel>> hareketeGoreGecmisGetir(String hareketId) async {
    final tumKayitlar = await tumGecmisKayitlariGetir();
    return tumKayitlar.where((kayit) => 
      kayit.hareketler.any((hareket) => hareket.hareketId == hareketId)
    ).toList();
  }

  @override
  Future<void> antrenmanSil(String id) async {
    final box = await Hive.openBox(_gecmisBoxName);
    await box.delete(id); 
  }

  // ========================================================
  // 2. YENİ: HAZIR ŞABLON (RUTİN) İŞLEMLERİ
  // ========================================================
  @override
  Future<void> rutinKaydet(AntrenmanRutiniModel rutin) async {
    final box = await Hive.openBox(_rutinBoxName);
    await box.put(rutin.id, rutin.toMap());
  }

  @override
  Future<List<AntrenmanRutiniModel>> tumRutinleriGetir() async {
    final box = await Hive.openBox(_rutinBoxName);
    final liste = <AntrenmanRutiniModel>[];
    
    for (var key in box.keys) {
      final map = box.get(key);
      if (map != null) {
        liste.add(AntrenmanRutiniModel.fromMap(map));
      }
    }
    
    return liste; // İstenirse burada alfabetik sıralama da yapılabilir
  }

  @override
  Future<void> rutinSil(String id) async {
    final box = await Hive.openBox(_rutinBoxName);
    await box.delete(id);
  }
}