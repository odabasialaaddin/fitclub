import '../../domain/entities/antrenman_entity.dart';

// 1. SET MODELİ: En alt katman. Ağırlık ve tekrar verilerini Hive'a yazar/okur.
class AntrenmanSetiModel extends AntrenmanSeti {
  const AntrenmanSetiModel({
    required super.setNo,
    required super.agirlik,
    required super.tekrar,
  });

  factory AntrenmanSetiModel.fromMap(Map<dynamic, dynamic> map) {
    return AntrenmanSetiModel(
      setNo: map['setNo'] as int,
      agirlik: (map['agirlik'] as num).toDouble(),
      tekrar: map['tekrar'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setNo': setNo,
      'agirlik': agirlik,
      'tekrar': tekrar,
    };
  }
}

// 2. YENİ ARA MODEL (HAREKET MODELİ): Bir hareketi ve o hareketin setlerini Hive'a yazar/okur.
class AntrenmanHareketiModel extends AntrenmanHareketi {
  const AntrenmanHareketiModel({
    required super.hareketId,
    required super.hareketAdi,
    required super.setler,
  });

  factory AntrenmanHareketiModel.fromMap(Map<dynamic, dynamic> map) {
    return AntrenmanHareketiModel(
      hareketId: map['hareketId'] as String,
      hareketAdi: map['hareketAdi'] as String,
      setler: (map['setler'] as List<dynamic>)
          .map((e) => AntrenmanSetiModel.fromMap(e as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hareketId': hareketId,
      'hareketAdi': hareketAdi,
      'setler': setler.map((e) {
        if (e is AntrenmanSetiModel) return e.toMap();
        return AntrenmanSetiModel(setNo: e.setNo, agirlik: e.agirlik, tekrar: e.tekrar).toMap();
      }).toList(),
    };
  }
}

// 3. ANA KAYIT MODELİ: Artık tek bir hareketi değil, "hareketler" listesini Hive'a yazar/okur.
class AntrenmanKaydiModel extends AntrenmanKaydi {
  const AntrenmanKaydiModel({
    required super.id,
    required super.tarih,
    required super.hareketler,
  });

  factory AntrenmanKaydiModel.fromMap(Map<dynamic, dynamic> map) {
    if (map['hareketler'] == null && map['setler'] != null) {
      return AntrenmanKaydiModel(
        id: map['id'] as String,
        tarih: DateTime.parse(map['tarih'] as String),
        hareketler: [
          AntrenmanHareketiModel(
            hareketId: map['hareketId'] as String? ?? 'eski_kayit',
            hareketAdi: map['hareketAdi'] as String? ?? 'Eski Antrenman',
            setler: (map['setler'] as List<dynamic>)
                .map((e) => AntrenmanSetiModel.fromMap(e as Map<dynamic, dynamic>))
                .toList(),
          )
        ],
      );
    }

    return AntrenmanKaydiModel(
      id: map['id'] as String,
      tarih: DateTime.parse(map['tarih'] as String),
      hareketler: (map['hareketler'] as List<dynamic>?)
          ?.map((e) => AntrenmanHareketiModel.fromMap(e as Map<dynamic, dynamic>))
          .toList() ?? [], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tarih': tarih.toIso8601String(),
      'hareketler': hareketler.map((e) {
        if (e is AntrenmanHareketiModel) return e.toMap();
        return AntrenmanHareketiModel(
          hareketId: e.hareketId,
          hareketAdi: e.hareketAdi,
          setler: e.setler,
        ).toMap();
      }).toList(),
    };
  }
}

// 4. YENİ EKLENEN MODEL: Kullanıcının Hazır Şablonlarını (Rutinleri) Hive'a yazar/okur.
class AntrenmanRutiniModel extends AntrenmanRutini {
  const AntrenmanRutiniModel({
    required super.id,
    required super.rutinAdi,
    required super.hareketler,
  });

  factory AntrenmanRutiniModel.fromMap(Map<dynamic, dynamic> map) {
    return AntrenmanRutiniModel(
      id: map['id'] as String,
      rutinAdi: map['rutinAdi'] as String,
      hareketler: (map['hareketler'] as List<dynamic>?)
          ?.map((e) => AntrenmanHareketiModel.fromMap(e as Map<dynamic, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rutinAdi': rutinAdi,
      'hareketler': hareketler.map((e) {
        if (e is AntrenmanHareketiModel) return e.toMap();
        return AntrenmanHareketiModel(
          hareketId: e.hareketId,
          hareketAdi: e.hareketAdi,
          setler: e.setler,
        ).toMap();
      }).toList(),
    };
  }
}