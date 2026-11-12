import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/antrenman_entity.dart';
import '../bloc/antrenman_cubit.dart';

class YeniRutinEkrani extends StatefulWidget {
  const YeniRutinEkrani({super.key});

  @override
  State<YeniRutinEkrani> createState() => _YeniRutinEkraniState();
}

class _YeniRutinEkraniState extends State<YeniRutinEkrani> {
  final TextEditingController _rutinAdiController = TextEditingController();
  final List<AntrenmanHareketi> _secilenHareketler = [];

  void _rutiniKaydet() {
    final rutinAdi = _rutinAdiController.text.trim();
    if (rutinAdi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen rutin için bir isim girin.", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_secilenHareketler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rutine en az bir hareket eklemelisiniz.", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final yeniRutin = AntrenmanRutini(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rutinAdi: rutinAdi,
      hareketler: _secilenHareketler,
    );

    context.read<AntrenmanCubit>().rutinKaydet(yeniRutin);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Rutin başarıyla oluşturuldu!"), backgroundColor: Colors.green),
    );
    context.pop();
  }

  @override
  void dispose() {
    _rutinAdiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Rutin Oluştur"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _rutinAdiController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                labelText: "Rutin Adı (Örn: İtme Günü)",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Hareketler",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final secilenHareket = await context.push<AntrenmanHareketi>('/rutinler/hareket-secim');
                    
                    if (secilenHareket != null) {
                      setState(() {
                        _secilenHareketler.add(secilenHareket);
                      });
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.greenAccent),
                  label: const Text("Hareket Ekle", style: TextStyle(color: Colors.greenAccent)),
                )
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            Expanded(
              child: _secilenHareketler.isEmpty
                  ? const Center(
                      child: Text(
                        "Henüz hareket eklenmedi.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _secilenHareketler.length,
                      itemBuilder: (context, index) {
                        final hareket = _secilenHareketler[index];
                        return Card(
                          color: Theme.of(context).colorScheme.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(hareket.hareketAdi, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text("${hareket.setler.length} Set", style: const TextStyle(color: Colors.grey)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _secilenHareketler.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _rutiniKaydet,
                child: const Text("Rutini Kaydet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}