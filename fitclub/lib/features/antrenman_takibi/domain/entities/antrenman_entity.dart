import 'package:equatable/equatable.dart';

// 1. En Alt Varlık: Tek bir setin (ağırlık ve tekrar) saf tanımı
class AntrenmanSeti extends Equatable {
  final int setNo;
  final double agirlik;
  final int tekrar;

  const AntrenmanSeti({
    required this.setNo,
    required this.agirlik,
    required this.tekrar,
  });

  @override
  List<Object?> get props => [setNo, agirlik, tekrar];
}

// 2. ARA VARLIK: Bir antrenman oturumunda veya ŞABLONDA bulunan tek bir hareket
class AntrenmanHareketi extends Equatable {
  final String hareketId;
  final String hareketAdi;
  final List<AntrenmanSeti> setler;

  const AntrenmanHareketi({
    required this.hareketId,
    required this.hareketAdi,
    required this.setler,
  });

  @override
  List<Object?> get props => [hareketId, hareketAdi, setler];
}

// 3. Ana Varlık: O gün yapılan tam antrenman oturumunun GEÇMİŞ KAYDI
class AntrenmanKaydi extends Equatable {
  final String id; 
  final DateTime tarih; 
  final List<AntrenmanHareketi> hareketler; 

  const AntrenmanKaydi({
    required this.id,
    required this.tarih,
    required this.hareketler,
  });

  @override
  List<Object?> get props => [id, tarih, hareketler];
}

// 4. YENİ EKLENEN VARLIK: Kullanıcının Hazır Antrenman Şablonu (Rutin)
class AntrenmanRutini extends Equatable {
  final String id; // Şablonun benzersiz ID'si
  final String rutinAdi; // Örn: "İtme Günü (Push)", "Yüzme Günü"
  final List<AntrenmanHareketi> hareketler; // Bu şablona eklenecek hareketler ve hedef setleri

  const AntrenmanRutini({
    required this.id,
    required this.rutinAdi,
    required this.hareketler,
  });

  @override
  List<Object?> get props => [id, rutinAdi, hareketler];
}