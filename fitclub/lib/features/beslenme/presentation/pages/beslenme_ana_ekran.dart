import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/beslenme_cubit.dart';
import '../bloc/beslenme_state.dart';
// ÇÖZÜM 1: Zeka küpünü bu sayfaya dahil ettik
import '../bloc/gunluk_beslenme_cubit.dart'; 
import '../../data/models/besin_model.dart';
import '../../data/models/tuketilen_besin_model.dart';

class BeslenmeAnaEkran extends StatefulWidget {
  const BeslenmeAnaEkran({super.key});

  @override
  State<BeslenmeAnaEkran> createState() => _BeslenmeAnaEkranState();
}

class _BeslenmeAnaEkranState extends State<BeslenmeAnaEkran> {
  final TextEditingController _aramaController = TextEditingController();

  void _gramajBottomSheetGoster(BuildContext context, BesinModel besin) {
    final TextEditingController gramController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                besin.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "100 gramında ${besin.calories.toStringAsFixed(0)} kcal var. Ne kadar tükettiniz?",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: gramController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Gram giriniz (Örn: 200)",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixText: "gram",
                  suffixStyle: const TextStyle(color: Colors.greenAccent),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final gram = double.tryParse(gramController.text.replaceAll(',', '.'));
                    
                    if (gram != null && gram > 0) {
                      final tuketilen = TuketilenBesinModel.olustur(orjinalBesin: besin, girilenGram: gram);
                      
                      // ÇÖZÜM 2: İşte eksik olan hayati kod! Oluşturulan paketi veritabanına gönderiyoruz.
                      context.read<GunlukBeslenmeCubit>().besinEkle(tuketilen);
                      
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${tuketilen.gram.toStringAsFixed(0)}g ${tuketilen.name} sepete eklendi!"),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  child: const Text("Ekle", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Makro ve Kalori Arama"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aramaController,
                    decoration: InputDecoration(
                      hintText: "Örn: tavuk, yulaf...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<BeslenmeCubit>().besinAra(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    if (_aramaController.text.isNotEmpty) {
                      context.read<BeslenmeCubit>().besinAra(_aramaController.text);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.search, color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          
          Expanded(
            child: BlocBuilder<BeslenmeCubit, BeslenmeState>(
              builder: (context, state) {
                if (state is BeslenmeLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                } else if (state is BeslenmeError) {
                  return Center(child: Text(state.mesaj, style: const TextStyle(color: Colors.red)));
                } else if (state is BeslenmeLoaded) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.besinler.length,
                    itemBuilder: (context, index) {
                      final besin = state.besinler[index];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Theme.of(context).colorScheme.surface,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _gramajBottomSheetGoster(context, besin),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        besin.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${besin.calories.toStringAsFixed(0)} kcal",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                                        ),
                                        const Text(
                                          "100g için",
                                          style: TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white24, height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _makroGosterici("Protein", "${besin.protein.toStringAsFixed(1)}g", Colors.blue),
                                    _makroGosterici("Karb", "${besin.carbs.toStringAsFixed(1)}g", Colors.orange),
                                    _makroGosterici("Yağ", "${besin.fat.toStringAsFixed(1)}g", Colors.red),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text("Makrolarını öğrenmek istediğiniz besini arayın.", style: TextStyle(color: Colors.grey)));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _makroGosterici(String baslik, String deger, Color renk) {
    return Column(
      children: [
        Text(baslik, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(deger, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}