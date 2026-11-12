import 'besin_model.dart';

class TuketilenBesinModel {
  final String id;
  final String name;
  final double gram; // Kullanıcının girdiği miktar
  final double calories; // Hesaplanmış net kalori
  final double protein; // Hesaplanmış net protein
  final double carbs; // Hesaplanmış net karb
  final double fat; // Hesaplanmış net yağ
  final DateTime tarih; // Hangi gün tüketildiği

  TuketilenBesinModel({
    required this.id,
    required this.name,
    required this.gram,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.tarih,
  });

  // 100 gramlık orjinal API verisi ve girilen gramaj ile yepyeni bir tüketim nesnesi yaratan akıllı fabrika
  factory TuketilenBesinModel.olustur({
    required BesinModel orjinalBesin,
    required double girilenGram,
  }) {
    // Çarpan matematiği (Örn: 250 gram girildiyse çarpan 2.5 olur)
    final carpan = girilenGram / 100;

    return TuketilenBesinModel(
      id: orjinalBesin.id,
      name: orjinalBesin.name,
      gram: girilenGram,
      calories: orjinalBesin.calories * carpan,
      protein: orjinalBesin.protein * carpan,
      carbs: orjinalBesin.carbs * carpan,
      fat: orjinalBesin.fat * carpan,
      tarih: DateTime.now(), // Sisteme eklendiği anki saat/tarih
    );
  }
  
  // Hive (Yerel Veritabanı) içine kaydetmek için JSON/Map formatına dönüştürücü
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gram': gram,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'tarih': tarih.toIso8601String(),
    };
  }

  // Hive veritabanından listeyi geri okurken kullanacağımız dönüştürücü
  factory TuketilenBesinModel.fromMap(Map<dynamic, dynamic> map) {
    return TuketilenBesinModel(
      id: map['id'],
      name: map['name'],
      gram: map['gram'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      tarih: DateTime.parse(map['tarih']),
    );
  }
}