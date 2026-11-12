import '../../domain/entities/antrenman_entity.dart';
import '../../domain/repositories/antrenman_repository.dart';
import '../datasources/antrenman_local_data_source.dart';
import '../models/antrenman_model.dart';

// Domain'deki sözleşmeyi (AntrenmanRepository) 'implements' ile alıp içini dolduruyoruz.
class AntrenmanRepositoryImpl implements AntrenmanRepository {
  final AntrenmanLocalDataSource localDataSource;

  AntrenmanRepositoryImpl(this.localDataSource);

  // ========================================================
  // 1. GEÇMİŞ ANTRENMAN İŞLEMLERİ
  // ========================================================
  @override
  Future<void> antrenmanKaydet(AntrenmanKaydi kayit) async {
    final model = AntrenmanKaydiModel(
      id: kayit.id,
      tarih: kayit.tarih,
      hareketler: kayit.hareketler.map((hareket) => AntrenmanHareketiModel(
        hareketId: hareket.hareketId,
        hareketAdi: hareket.hareketAdi,
        setler: hareket.setler.map((s) => AntrenmanSetiModel(
          setNo: s.setNo,
          agirlik: s.agirlik,
          tekrar: s.tekrar,
        )).toList(),
      )).toList(),
    );

    await localDataSource.antrenmanKaydet(model);
  }

  @override
  Future<List<AntrenmanKaydi>> tumGecmisKayitlariGetir() async {
    return await localDataSource.tumGecmisKayitlariGetir();
  }

  @override
  Future<List<AntrenmanKaydi>> hareketeGoreGecmisGetir(String hareketId) async {
    return await localDataSource.hareketeGoreGecmisGetir(hareketId);
  }

  @override
  Future<void> antrenmanSil(String id) async {
    await localDataSource.antrenmanSil(id);
  }

  // ========================================================
  // 2. YENİ: HAZIR ŞABLON (RUTİN) İŞLEMLERİ
  // ========================================================
  @override
  Future<void> rutinKaydet(AntrenmanRutini rutin) async {
    // UI'dan gelen saf Rutin nesnesini, veritabanının anlayacağı Modele dönüştürüyoruz
    final model = AntrenmanRutiniModel(
      id: rutin.id,
      rutinAdi: rutin.rutinAdi,
      hareketler: rutin.hareketler.map((hareket) => AntrenmanHareketiModel(
        hareketId: hareket.hareketId,
        hareketAdi: hareket.hareketAdi,
        setler: hareket.setler.map((s) => AntrenmanSetiModel(
          setNo: s.setNo,
          agirlik: s.agirlik,
          tekrar: s.tekrar,
        )).toList(),
      )).toList(),
    );

    await localDataSource.rutinKaydet(model);
  }

  @override
  Future<List<AntrenmanRutini>> tumRutinleriGetir() async {
    return await localDataSource.tumRutinleriGetir();
  }

  @override
  Future<void> rutinSil(String id) async {
    await localDataSource.rutinSil(id);
  }
}