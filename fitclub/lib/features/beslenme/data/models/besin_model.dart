class BesinModel {
  final String id; // Besinin sistemdeki benzersiz kodu (Barkod vb.)
  final String name; // Besinin adı
  final double calories; // Kalori değeri (kcal)
  final double protein; // Protein değeri (gram)
  final double carbs; // Karbonhidrat değeri (gram)
  final double fat; // Yağ değeri (gram)
  final String? imageUrl; // Besinin fotoğrafı (Eğer API'de varsa)

  BesinModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl,
  });

  // İNTERNETTEN GELEN VERİYİ DART NESNESİNE ÇEVİREN FABRİKA
  factory BesinModel.fromJson(Map<String, dynamic> json) {
    // Open Food Facts API'si makro değerleri doğrudan dışarıda değil, 
    // 'nutriments' (besin ögeleri) adında alt bir listenin içinde gönderir. Önce onu yakalıyoruz.
    final nutriments = json['nutriments'] ?? {};

    return BesinModel(
      // JSON içindeki '_id' alanını alıyoruz
      id: json['_id'] ?? '',
      
      // Ürün adını alıyoruz, yoksa 'Bilinmeyen Besin' yazdırıyoruz
      name: json['product_name'] ?? 'Bilinmeyen Besin',
      
      // API değerleri bazen tam sayı (10) bazen ondalıklı (10.5) gönderebilir. 
      // Çökme olmaması için önce okuyup zorla ondalıklı sayıya (.toDouble()) çeviriyoruz.
      // Not: Değerleri 100 gram üzerinden ('_100g') çekiyoruz ki hesaplamamız standart olsun.
      calories: (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
      protein: (nutriments['proteins_100g'] ?? 0).toDouble(),
      carbs: (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
      fat: (nutriments['fat_100g'] ?? 0).toDouble(),
      
      // Ürünün fotoğrafı
      imageUrl: json['image_front_url'] ?? json['image_url'],
    );
  }
}