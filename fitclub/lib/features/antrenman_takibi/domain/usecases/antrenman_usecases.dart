import '../entities/antrenman_entity.dart';
import '../repositories/antrenman_repository.dart';

// ========================================================
// 1. GEÇMİŞ ANTRENMAN KOMUTANLARI (USE CASE'LER)
// ========================================================
class AntrenmanKaydetUseCase {
  final AntrenmanRepository repository;
  AntrenmanKaydetUseCase(this.repository);

  Future<void> call(AntrenmanKaydi kayit) async {
    return await repository.antrenmanKaydet(kayit);
  }
}

class TumGecmisKayitlariGetirUseCase {
  final AntrenmanRepository repository;
  TumGecmisKayitlariGetirUseCase(this.repository);

  Future<List<AntrenmanKaydi>> call() async {
    return await repository.tumGecmisKayitlariGetir();
  }
}

class HareketeGoreGecmisGetirUseCase {
  final AntrenmanRepository repository;
  HareketeGoreGecmisGetirUseCase(this.repository);

  Future<List<AntrenmanKaydi>> call(String hareketId) async {
    return await repository.hareketeGoreGecmisGetir(hareketId);
  }
}

class AntrenmanSilUseCase {
  final AntrenmanRepository repository;
  AntrenmanSilUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.antrenmanSil(id);
  }
}

// ========================================================
// 2. YENİ: HAZIR ŞABLON (RUTİN) KOMUTANLARI (USE CASE'LER)
// ========================================================
class RutinKaydetUseCase {
  final AntrenmanRepository repository;
  RutinKaydetUseCase(this.repository);

  Future<void> call(AntrenmanRutini rutin) async {
    return await repository.rutinKaydet(rutin);
  }
}

class TumRutinleriGetirUseCase {
  final AntrenmanRepository repository;
  TumRutinleriGetirUseCase(this.repository);

  Future<List<AntrenmanRutini>> call() async {
    return await repository.tumRutinleriGetir();
  }
}

class RutinSilUseCase {
  final AntrenmanRepository repository;
  RutinSilUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.rutinSil(id);
  }
}