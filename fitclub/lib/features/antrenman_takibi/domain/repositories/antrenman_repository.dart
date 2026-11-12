import '../entities/antrenman_entity.dart';

// Beynimizin (Domain) veritabanından (Data) istediklerinin sözleşmesi
abstract class AntrenmanRepository {
  // --- 1. GEÇMİŞ ANTRENMAN İŞLEMLERİ ---
  Future<void> antrenmanKaydet(AntrenmanKaydi kayit);
  Future<List<AntrenmanKaydi>> tumGecmisKayitlariGetir();
  Future<List<AntrenmanKaydi>> hareketeGoreGecmisGetir(String hareketId);
  Future<void> antrenmanSil(String id);

  // --- 2. YENİ: HAZIR ŞABLON (RUTİN) İŞLEMLERİ ---
  Future<void> rutinKaydet(AntrenmanRutini rutin);
  Future<List<AntrenmanRutini>> tumRutinleriGetir();
  Future<void> rutinSil(String id);
}