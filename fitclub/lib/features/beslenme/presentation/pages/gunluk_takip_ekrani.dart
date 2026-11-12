import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/gunluk_beslenme_cubit.dart';

class GunlukTakipEkrani extends StatefulWidget {
  const GunlukTakipEkrani({super.key});

  @override
  State<GunlukTakipEkrani> createState() => _GunlukTakipEkraniState();
}

class _GunlukTakipEkraniState extends State<GunlukTakipEkrani> {
  @override
  void initState() {
    super.initState();
    context.read<GunlukBeslenmeCubit>().gunlukVerileriGetir();
  }

  void _hedefBelirleBottomSheet(BuildContext context, double mevcutHedef) {
    final TextEditingController hedefController = TextEditingController(text: mevcutHedef.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Günlük Kalori Hedefi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text("Kendi vücut tipinize ve amacınıza göre günlük hedefinizi belirleyin.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                controller: hedefController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  suffixText: "kcal",
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
                    final yeniHedef = double.tryParse(hedefController.text);
                    if (yeniHedef != null && yeniHedef > 0) {
                      context.read<GunlukBeslenmeCubit>().hedefKaloriGuncelle(yeniHedef);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Hedefi Güncelle", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        title: const Text("Günlük Özet"),
        centerTitle: true,
      ),
      body: BlocBuilder<GunlukBeslenmeCubit, GunlukBeslenmeState>(
        builder: (context, state) {
          if (state is GunlukBeslenmeLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          } else if (state is GunlukBeslenmeError) {
            return Center(child: Text(state.mesaj, style: const TextStyle(color: Colors.red)));
          } else if (state is GunlukBeslenmeLoaded) {
            
            double kalanKalori = state.hedefKalori - state.toplamKalori;
            if (kalanKalori < 0) kalanKalori = 0;

            return Column(
              children: [
                const SizedBox(height: 20),
                
                SizedBox(
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ÇÖZÜM: Katman sırasını değiştirdik! Önce grafiği ALTA çiziyoruz.
                      PieChart(
                        PieChartData(
                          sectionsSpace: 4, 
                          centerSpaceRadius: 90, 
                          startDegreeOffset: -90, 
                          sections: [
                            if (state.toplamProtein > 0)
                              PieChartSectionData(color: Colors.blueAccent, value: state.toplamProtein * 4, title: "", radius: 15),
                            if (state.toplamKarb > 0)
                              PieChartSectionData(color: Colors.orangeAccent, value: state.toplamKarb * 4, title: "", radius: 15),
                            if (state.toplamYag > 0)
                              PieChartSectionData(color: Colors.redAccent, value: state.toplamYag * 9, title: "", radius: 15),
                            if (kalanKalori > 0)
                              PieChartSectionData(color: Colors.grey.shade900, value: kalanKalori, title: "", radius: 15),
                          ],
                        ),
                      ),

                      // Sonra butonu barındıran yazıları grafiğin ÜSTÜNE koyuyoruz.
                      // Böylece şeffaf grafiğin altında ezilmiyor, tıklanabilir hale geliyor.
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.toplamKalori.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, height: 1),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "/ ${state.hedefKalori.toStringAsFixed(0)} kcal",
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _hedefBelirleBottomSheet(context, state.hedefKalori),
                                // Tıklama alanını genişletmek için şeffaf arka plan rengi ekledik
                                behavior: HitTestBehavior.opaque, 
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.edit, size: 18, color: Colors.greenAccent),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _makroKutusu("Protein", state.toplamProtein, Colors.blueAccent),
                    _makroKutusu("Karb", state.toplamKarb, Colors.orangeAccent),
                    _makroKutusu("Yağ", state.toplamYag, Colors.redAccent),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Divider(color: Colors.white24),
                ),
                
                Expanded(
                  child: state.bugunTuketilenler.isEmpty
                    ? const Center(child: Text("Bugün henüz bir şey yemediniz.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.bugunTuketilenler.length,
                        itemBuilder: (context, index) {
                          final besin = state.bugunTuketilenler[index];
                          
                          return Dismissible(
                            key: Key(besin.tarih.toIso8601String()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              context.read<GunlukBeslenmeCubit>().besinSil(besin.tarih);
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.black26,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade900)),
                              child: ListTile(
                                title: Text(besin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${besin.gram.toStringAsFixed(0)} gram", style: const TextStyle(color: Colors.grey)),
                                trailing: Text(
                                  "${besin.calories.toStringAsFixed(0)} kcal",
                                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _makroKutusu(String baslik, double deger, Color renk) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: renk),
            const SizedBox(width: 6),
            Text(baslik, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text("${deger.toStringAsFixed(1)}g", style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}