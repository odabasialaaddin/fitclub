import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/tuketilen_besin_model.dart';

// --------------------------------------------------
// 1. BÖLÜM: STATE (DURUM) SINIFLARI
// --------------------------------------------------
abstract class GunlukBeslenmeState {}

class GunlukBeslenmeInitial extends GunlukBeslenmeState {}

class GunlukBeslenmeLoading extends GunlukBeslenmeState {}

class GunlukBeslenmeLoaded extends GunlukBeslenmeState {
  final List<TuketilenBesinModel> bugunTuketilenler;
  final double toplamKalori;
  final double toplamProtein;
  final double toplamKarb;
  final double toplamYag;
  // ÇÖZÜM 1: Ekrana göndereceğimiz pakete "hedefKalori" bilgisini ekledik
  final double hedefKalori; 

  GunlukBeslenmeLoaded({
    required this.bugunTuketilenler,
    required this.toplamKalori,
    required this.toplamProtein,
    required this.toplamKarb,
    required this.toplamYag,
    required this.hedefKalori,
  });
}

class GunlukBeslenmeError extends GunlukBeslenmeState {
  final String mesaj;
  GunlukBeslenmeError(this.mesaj);
}

// --------------------------------------------------
// 2. BÖLÜM: CUBIT (ZEKA KÜPÜ)
// --------------------------------------------------
class GunlukBeslenmeCubit extends Cubit<GunlukBeslenmeState> {
  GunlukBeslenmeCubit() : super(GunlukBeslenmeInitial()) {
    gunlukVerileriGetir();
  }

  final String _boxName = 'gunluk_beslenme_box';
  // ÇÖZÜM 2: Hedef gibi kalıcı ayarları tutmak için yeni bir Hive kutusu adı belirledik
  final String _ayarlarBox = 'ayarlar_box'; 

  Future<void> gunlukVerileriGetir() async {
    emit(GunlukBeslenmeLoading());
    try {
      var box = await Hive.openBox(_boxName);
      var ayarlar = await Hive.openBox(_ayarlarBox);
      
      // Veritabanında daha önce kaydedilmiş bir hedef yoksa varsayılan olarak 2500 belirler
      double hedef = ayarlar.get('hedefKalori', defaultValue: 2500.0);

      List<TuketilenBesinModel> liste = [];
      for (var item in box.values) {
        liste.add(TuketilenBesinModel.fromMap(item));
      }

      final bugun = DateTime.now();
      final bugunkuListe = liste.where((besin) => 
        besin.tarih.year == bugun.year && 
        besin.tarih.month == bugun.month && 
        besin.tarih.day == bugun.day
      ).toList();

      _hesaplaVeEkranaGonder(bugunkuListe, hedef);
    } catch (e) {
      emit(GunlukBeslenmeError("Veriler yüklenirken hata oluştu."));
    }
  }

  // ÇÖZÜM 3: Kullanıcının yeni belirlediği kalori hedefini veritabanına kaydeden fonksiyon
  Future<void> hedefKaloriGuncelle(double yeniHedef) async {
    try {
      var ayarlar = await Hive.openBox(_ayarlarBox);
      await ayarlar.put('hedefKalori', yeniHedef);
      // Hedef güncellendiğinde ekranın yeni hedefe göre tekrar çizilmesini tetikler
      await gunlukVerileriGetir(); 
    } catch (e) {
      emit(GunlukBeslenmeError("Hedef kaydedilemedi."));
    }
  }

  Future<void> besinEkle(TuketilenBesinModel besin) async {
    try {
      var box = await Hive.openBox(_boxName);
      await box.add(besin.toMap());
      await gunlukVerileriGetir();
    } catch (e) {
      emit(GunlukBeslenmeError("Besin kaydedilemedi."));
    }
  }

  Future<void> besinSil(DateTime eklenmeTarihi) async {
    try {
      var box = await Hive.openBox(_boxName);
      final silinecekKey = box.keys.firstWhere((k) {
        final item = box.get(k);
        return item['tarih'] == eklenmeTarihi.toIso8601String();
      }, orElse: () => null);

      if (silinecekKey != null) {
        await box.delete(silinecekKey);
        await gunlukVerileriGetir();
      }
    } catch (e) {
      emit(GunlukBeslenmeError("Besin silinemedi."));
    }
  }

  void _hesaplaVeEkranaGonder(List<TuketilenBesinModel> liste, double hedef) {
    double cal = 0, pro = 0, kar = 0, yag = 0;
    
    for (var b in liste) {
      cal += b.calories;
      pro += b.protein;
      kar += b.carbs;
      yag += b.fat;
    }

    emit(GunlukBeslenmeLoaded(
      bugunTuketilenler: liste,
      toplamKalori: cal,
      toplamProtein: pro,
      toplamKarb: kar,
      toplamYag: yag,
      hedefKalori: hedef, // UI'a yeni hedefi de paslıyoruz
    ));
  }
}