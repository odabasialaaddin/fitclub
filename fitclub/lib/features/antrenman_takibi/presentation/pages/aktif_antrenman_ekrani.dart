import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../egzersiz/data/models/egzersiz_model.dart';
import '../../domain/entities/antrenman_entity.dart';
import '../bloc/antrenman_cubit.dart';

class AktifAntrenmanEkrani extends StatefulWidget {
  final EgzersizModel hareket;

  const AktifAntrenmanEkrani({super.key, required this.hareket});

  @override
  State<AktifAntrenmanEkrani> createState() => _AktifAntrenmanEkraniState();
}

class _AktifAntrenmanEkraniState extends State<AktifAntrenmanEkrani> {
  final List<AntrenmanSeti> _tamamlananSetler = [];
  
  final TextEditingController _agirlikController = TextEditingController();
  final TextEditingController _tekrarController = TextEditingController();

  Timer? _timer;
  int _kalanSaniye = 0;
  final int _dinlenmeSuresi = 90;

  void _setiBitirVeDinlenmeyeGec() {
    final agirlik = double.tryParse(_agirlikController.text.replaceAll(',', '.')) ?? 0.0;
    final tekrar = int.tryParse(_tekrarController.text) ?? 0;

    if (tekrar == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen geçerli bir tekrar sayısı girin."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _tamamlananSetler.add(
        AntrenmanSeti(
          setNo: _tamamlananSetler.length + 1,
          agirlik: agirlik,
          tekrar: tekrar,
        ),
      );
      
      _agirlikController.clear();
      _tekrarController.clear();
      FocusScope.of(context).unfocus(); 
      
      _kalanSaniye = _dinlenmeSuresi;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_kalanSaniye > 0) {
        setState(() {
          _kalanSaniye--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  // YENİ SEÇENEK 1: Sadece hareketi sepete ekler ve yeni hareket seçmesi için kütüphaneye döner
  void _hareketiSepeteEkle() {
    final yapilanHareket = AntrenmanHareketi(
      hareketId: widget.hareket.id,
      hareketAdi: widget.hareket.name,
      setler: _tamamlananSetler,
    );

    context.read<AntrenmanCubit>().sepeteHareketEkle(yapilanHareket);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Hareket sepete eklendi! Listeden yeni hareket seçebilirsiniz."), 
        backgroundColor: Colors.orangeAccent
      ),
    );
    Navigator.pop(context); // Kütüphaneye geri dön
  }

  // YENİ SEÇENEK 2: Sepeti komple veritabanına yazar (Antrenmanı bitirir)
  void _antrenmaniKompleBitir() {
    // Eğer ekranda yapılmış ama sepete henüz atılmamış setler varsa önce onları sepete at
    if (_tamamlananSetler.isNotEmpty) {
      final yapilanHareket = AntrenmanHareketi(
        hareketId: widget.hareket.id,
        hareketAdi: widget.hareket.name,
        setler: _tamamlananSetler,
      );
      context.read<AntrenmanCubit>().sepeteHareketEkle(yapilanHareket);
    }

    // Cubit'e sepeti veritabanına kaydetme emri ver
    context.read<AntrenmanCubit>().aktifAntrenmaniKaydet();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tüm Antrenman başarıyla kaydedildi! 🚀"), backgroundColor: Colors.green),
    );
    Navigator.pop(context); // Kütüphaneye/Ana sayfaya geri dön
  }

  @override
  void dispose() {
    _timer?.cancel();
    _agirlikController.dispose();
    _tekrarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aktif Antrenman"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. MİNİ ODAK REHBERİ
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.hareket.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.hareket.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(width: 60, height: 60, color: Colors.grey.shade800),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.hareket.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 4),
                      const Text("Serbest Ağırlık / Makine", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // 2. NEON KRONOMETRE
          if (_kalanSaniye > 0)
            Column(
              children: [
                const Text("Dinlenme Süresi", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: _kalanSaniye / _dinlenmeSuresi,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade900,
                        color: Colors.greenAccent,
                      ),
                    ),
                    Text(
                      "$_kalanSaniye",
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),

          // 3. SET GİRİŞ ALANI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _agirlikController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Ağırlık (kg)",
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _tekrarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Tekrar",
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _kalanSaniye > 0 ? null : _setiBitirVeDinlenmeyeGec,
                  child: const Icon(Icons.check),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Divider(color: Colors.white24),
          ),

          // 4. GEÇMİŞ SETLER LİSTESİ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tamamlananSetler.length,
              itemBuilder: (context, index) {
                final setBilgisi = _tamamlananSetler[index];
                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.greenAccent.withOpacity(0.2),
                      child: Text("${setBilgisi.setNo}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ),
                    title: Text("${setBilgisi.agirlik} kg × ${setBilgisi.tekrar} Tekrar"),
                    trailing: const Icon(Icons.fitness_center, color: Colors.grey, size: 20),
                  ),
                );
              },
            ),
          ),
          
          // 5. ÇOKLU HAREKET BUTONLARI (Sepet Mantığı)
          if (_tamamlananSetler.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Hareketi Sepete Ekle Butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orangeAccent,
                        side: const BorderSide(color: Colors.orangeAccent),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _hareketiSepeteEkle,
                      child: const Text("Hareketi Tamamla (Başka Ekle)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tüm Antrenmanı Bitir Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _antrenmaniKompleBitir,
                      child: const Text("Tüm Antrenmanı Bitir ve Kaydet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}