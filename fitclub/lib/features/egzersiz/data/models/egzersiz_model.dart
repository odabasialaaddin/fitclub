class EgzersizModel {
  final String id; 
  final String name; 
  final String description; 
  final String? imageUrl; 

  EgzersizModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  factory EgzersizModel.fromJson(Map<String, dynamic> json) {
    String aciklamaOlustur() {
      if (json['instructions'] != null && json['instructions'] is List) {
        return (json['instructions'] as List).join('\n\n'); 
      }
      return 'Bu hareket için açıklama bulunamadı.';
    }

    String? resimBul() {
      if (json['images'] != null && json['images'] is List && (json['images'] as List).isNotEmpty) {
        final yarimYol = json['images'][0].toString();
        // DİKKAT: URL'de boşluklar olduğu için Uri.encodeFull kullanmak zorundayız. 
        // Yoksa CachedNetworkImage linki bozuk sanıp hata ikonuna (halter) döner.
        return Uri.encodeFull('https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$yarimYol');
      }
      return null;
    }

    return EgzersizModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), 
      name: json['name'] ?? 'Bilinmeyen Hareket',
      description: aciklamaOlustur(),
      imageUrl: resimBul(), 
    );
  }
}