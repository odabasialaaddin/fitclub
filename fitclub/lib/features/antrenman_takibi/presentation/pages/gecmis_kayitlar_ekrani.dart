import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/antrenman_cubit.dart';
import '../bloc/antrenman_state.dart';
import '../../domain/entities/antrenman_entity.dart';

class GecmisKayitlarEkrani extends StatefulWidget {
  const GecmisKayitlarEkrani({super.key});

  @override
  State<GecmisKayitlarEkrani> createState() => _GecmisKayitlarEkraniState();
}

class _GecmisKayitlarEkraniState extends State<GecmisKayitlarEkrani> {
  @override
  void initState() {
    super.initState();
    context.read<AntrenmanCubit>().gecmisKayitlariGetir();
  }

  String _tarihFormatla(DateTime tarih) {
    return "${tarih.day.toString().padLeft(2, '0')}.${tarih.month.toString().padLeft(2, '0')}.${tarih.year} - ${tarih.hour.toString().padLeft(2, '0')}:${tarih.minute.toString().padLeft(2, '0')}";
  }

  // Silme Onay Diyaloğu (Metni yeni çoklu yapıya göre güncellendi)
  void _silmeOnayiIste(BuildContext context, AntrenmanKaydi kayit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text("Oturumu Sil", style: TextStyle(color: Colors.redAccent)),
          content: const Text("Bu antrenman oturumunu (içindeki tüm hareketler ve setlerle birlikte) silmek istediğinize emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(context);
                context.read<AntrenmanCubit>().antrenmaniSil(kayit.id);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Antrenman oturumu silindi."),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: const Text("Evet, Sil", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Antrenman Geçmişim"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<AntrenmanCubit, AntrenmanState>(
        builder: (context, state) {
          if (state is AntrenmanLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          } else if (state is AntrenmanError) {
            return Center(
              child: Text(
                state.mesaj,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          } else if (state is AntrenmanLoaded) {
            final kayitlar = state.gecmisKayitlar;

            if (kayitlar.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade700),
                    const SizedBox(height: 16),
                    const Text(
                      "Henüz hiç antrenman kaydın yok.\nHadi ilk setini at!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kayitlar.length,
              itemBuilder: (context, index) {
                final kayit = kayitlar[index];
                
                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KARTIN ÜST KISMI: Artık sadece Tarih ve Çöp Kutusu var
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _tarihFormatla(kayit.tarih),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _silmeOnayiIste(context, kayit),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 16),
                        
                        // KARTIN GÖVDESİ: Oturumun içindeki tüm HAREKETLERİ döngüye alıyoruz
                        ...kayit.hareketler.map((hareket) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hareket Adı (Örn: Biceps Curl)
                                Text(
                                  hareket.hareketAdi,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // O harekete ait SETLERİ döngüye alıyoruz
                                ...hareket.setler.map((setInfo) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade800,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text("Set ${setInfo.setNo}", style: const TextStyle(fontSize: 12)),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "${setInfo.agirlik} kg",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const Text(" × ", style: TextStyle(color: Colors.grey)),
                                        Text(
                                          "${setInfo.tekrar} Tekrar",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}