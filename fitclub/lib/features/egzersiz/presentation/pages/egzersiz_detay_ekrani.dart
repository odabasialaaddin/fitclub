import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:translator/translator.dart';
import '../../data/models/egzersiz_model.dart';

// YENİ EKLENEN: Butona basılınca gidilecek aktif antrenman ekranının yolu
import '../../../antrenman_takibi/presentation/pages/aktif_antrenman_ekrani.dart';

class EgzersizDetayEkrani extends StatefulWidget {
  final EgzersizModel hareket;

  const EgzersizDetayEkrani({super.key, required this.hareket});

  @override
  State<EgzersizDetayEkrani> createState() => _EgzersizDetayEkraniState();
}

class _EgzersizDetayEkraniState extends State<EgzersizDetayEkrani> {
  final _translator = GoogleTranslator();
  String _cevrilmisAciklama = "";
  bool _ceviriliyor = true;

  @override
  void initState() {
    super.initState();
    _ceviriYap();
  }

  Future<void> _ceviriYap() async {
    try {
      final ceviri = await _translator.translate(widget.hareket.description, from: 'en', to: 'tr');
      setState(() {
        _cevrilmisAciklama = ceviri.text;
        _ceviriliyor = false;
      });
    } catch (e) {
      setState(() {
        _cevrilmisAciklama = widget.hareket.description; 
        _ceviriliyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hareket.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Buton ekranın altını kapatmasın diye en alta fazladan 80px boşluk koyuyoruz
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.hareket.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.hareket.imageUrl!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox(
                            height: 250,
                            child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
                          ),
                          errorWidget: (context, url, error) => _HataIkonu(),
                        )
                      : _HataIkonu(),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                widget.hareket.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Nasıl Yapılır?",
                style: TextStyle(fontSize: 18, color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: _ceviriliyor
                    ? const Row(
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text("Yapay Zeka Türkçe'ye çeviriyor...", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : Text(
                        _cevrilmisAciklama,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
                      ),
              ),
            ],
          ),
        ),
      ),
      // YENİ EKLENEN: Alt tarafta havada asılı duran (Floating) "Antrenmana Başla" Butonu
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AktifAntrenmanEkrani(hareket: widget.hareket),
            ),
          );
        },
        backgroundColor: Colors.greenAccent,
        icon: const Icon(Icons.play_arrow, color: Colors.black),
        label: const Text(
          "Antrenmana Başla", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _HataIkonu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey.shade900,
      child: const Icon(Icons.fitness_center, size: 80, color: Colors.greenAccent),
    );
  }
}