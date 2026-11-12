import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../egzersiz/presentation/bloc/egzersiz_cubit.dart';
import '../../../egzersiz/data/models/egzersiz_model.dart';
import '../../domain/entities/antrenman_entity.dart';

class RutinHareketSecimEkrani extends StatefulWidget {
  const RutinHareketSecimEkrani({super.key});

  @override
  State<RutinHareketSecimEkrani> createState() => _RutinHareketSecimEkraniState();
}

class _RutinHareketSecimEkraniState extends State<RutinHareketSecimEkrani> {
  void _hedefSetVeDegerBelirle(EgzersizModel hareket) {
    int setSayisi = 3;
    double varsayilanAgirlik = 0.0;
    int varsayilanTekrar = 10;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text("${hareket.name} Şablonu", style: const TextStyle(color: Colors.greenAccent)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Hedef Set Sayısı:", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (setSayisi > 1) setStateDialog(() => setSayisi--);
                          },
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                        ),
                        Text("$setSayisi Set", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        IconButton(
                          onPressed: () => setStateDialog(() => setSayisi++),
                          icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Varsayılan Hedef Değerler:", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Kg",
                              labelStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                            onChanged: (val) {
                              varsayilanAgirlik = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Tekrar",
                              labelStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                            onChanged: (val) {
                              varsayilanTekrar = int.tryParse(val) ?? 10;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text("İptal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                  onPressed: () {
                    List<AntrenmanSeti> hedefSetler = List.generate(
                      setSayisi,
                      (index) => AntrenmanSeti(
                        setNo: index + 1, 
                        agirlik: varsayilanAgirlik, 
                        tekrar: varsayilanTekrar,
                      ),
                    );

                    final rutinHareketi = AntrenmanHareketi(
                      hareketId: hareket.id,
                      hareketAdi: hareket.name,
                      setler: hedefSetler,
                    );

                    context.pop(); // Dialog'u kapatır
                    context.pop(rutinHareketi); // Sayfayı kapatıp seçilen hareketi geri döndürür
                  },
                  child: const Text("Şablona Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  List<EgzersizModel> _egzersizListesiniCikar(dynamic state) {
    try {
      if (state.egzersizler != null) {
        return List<EgzersizModel>.from(state.egzersizler);
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kütüphaneden Seç"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<EgzersizCubit, dynamic>(
        builder: (context, state) {
          final egzersizler = _egzersizListesiniCikar(state);
          
          if (egzersizler.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: egzersizler.length,
            itemBuilder: (context, index) {
              final hareket = egzersizler[index];
              return Card(
                color: Theme.of(context).colorScheme.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: hareket.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: hareket.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Container(width: 50, height: 50, color: Colors.grey.shade800),
                  ),
                  title: Text(hareket.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  trailing: const Icon(Icons.add_circle, color: Colors.greenAccent),
                  onTap: () => _hedefSetVeDegerBelirle(hareket),
                ),
              );
            },
          );
        },
      ),
    );
  }
}