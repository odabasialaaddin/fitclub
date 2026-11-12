import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/antrenman_entity.dart';
import '../bloc/antrenman_cubit.dart';
import '../bloc/aktif_antrenman_cubit.dart';
import '../bloc/aktif_antrenman_state.dart';

class AktifRutinEkrani extends StatelessWidget {
  final AntrenmanRutini rutin;

  const AktifRutinEkrani({super.key, required this.rutin});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AktifAntrenmanCubit()..antrenmanaBasla(rutin),
      child: const _AktifRutinEkraniIcerik(),
    );
  }
}

class _AktifRutinEkraniIcerik extends StatefulWidget {
  const _AktifRutinEkraniIcerik();

  @override
  State<_AktifRutinEkraniIcerik> createState() => _AktifRutinEkraniIcerikState();
}

class _AktifRutinEkraniIcerikState extends State<_AktifRutinEkraniIcerik> {
  final TextEditingController _agirlikController = TextEditingController();
  final TextEditingController _tekrarController = TextEditingController();

  void _controllerleriGuncelle(AktifAntrenmanDevamEdiyor state) {
    if (state.aktifHareketIndex < state.rutin.hareketler.length) {
      final hareket = state.rutin.hareketler[state.aktifHareketIndex];
      if (state.aktifSetIndex < hareket.setler.length) {
        final set = hareket.setler[state.aktifSetIndex];
        
        if (_agirlikController.text.isEmpty || !state.dinlenmeModu) {
          _agirlikController.text = set.agirlik > 0 ? set.agirlik.toString() : "";
          _tekrarController.text = set.tekrar > 0 ? set.tekrar.toString() : "";
        }
      }
    }
  }

  void _antrenmaniKaydetVeBitir(BuildContext context, AntrenmanRutini rutin) {
    context.read<AntrenmanCubit>().sepetiTemizle();
    for (var hareket in rutin.hareketler) {
      context.read<AntrenmanCubit>().sepeteHareketEkle(hareket);
    }
    context.read<AntrenmanCubit>().aktifAntrenmaniKaydet();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 64),
            SizedBox(height: 16),
            Text("Tebrikler!", style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Antrenmanı başarıyla tamamladın. Kayıtların geçmişe eklendi.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () {
              context.pop(); // Dialog'u kapat
              context.pop(); // Sayfayı kapatıp ana ekrana dön
            },
            child: const Text("Bitir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      )
    );
  }

  @override
  void dispose() {
    _agirlikController.dispose();
    _tekrarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AktifAntrenmanCubit, AktifAntrenmanState>(
      listener: (context, state) {
        if (state is AktifAntrenmanDevamEdiyor) {
          if (state.tamamlandi) {
            _antrenmaniKaydetVeBitir(context, state.rutin);
          } else {
            _controllerleriGuncelle(state);
          }
        }
      },
      builder: (context, state) {
        if (state is! AktifAntrenmanDevamEdiyor) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)));
        }

        if (state.tamamlandi) {
          return const Scaffold();
        }

        final hareket = state.rutin.hareketler[state.aktifHareketIndex];
        final toplamHareket = state.rutin.hareketler.length;

        return Scaffold(
          appBar: AppBar(
            title: Text(state.rutin.rutinAdi),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (state.aktifHareketIndex + 1) / toplamHareket,
                backgroundColor: Colors.grey.shade900,
                color: Colors.greenAccent,
                minHeight: 6,
              ),
              const SizedBox(height: 16),
              Text(
                "Hareket ${state.aktifHareketIndex + 1} / $toplamHareket",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  hareket.hareketAdi,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: state.dinlenmeModu 
                    ? _buildDinlenmeEkrani(context, state.kalanSure) 
                    : _buildSetListesi(context, hareket, state.aktifSetIndex),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDinlenmeEkrani(BuildContext context, int kalanSure) {
    int dakika = kalanSure ~/ 60;
    int saniye = kalanSure % 60;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined, size: 80, color: Colors.blueAccent),
        const SizedBox(height: 24),
        const Text("Dinlenme Süresi", style: TextStyle(color: Colors.grey, fontSize: 20)),
        const SizedBox(height: 8),
        Text(
          "${dakika.toString().padLeft(2, '0')}:${saniye.toString().padLeft(2, '0')}",
          style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => context.read<AktifAntrenmanCubit>().sureEkle(30),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                side: const BorderSide(color: Colors.blueAccent),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text("+30 sn", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => context.read<AktifAntrenmanCubit>().dinlenmeyiBitir(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text("Atla", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSetListesi(BuildContext context, AntrenmanHareketi hareket, int aktifSetIndex) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: hareket.setler.length,
      itemBuilder: (context, index) {
        final set = hareket.setler[index];
        final bool tamamlandi = index < aktifSetIndex;
        final bool aktif = index == aktifSetIndex;
        
        return Card(
          color: aktif ? Colors.greenAccent.withOpacity(0.08) : Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: aktif ? const BorderSide(color: Colors.greenAccent, width: 1.5) : BorderSide.none,
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: tamamlandi ? Colors.green : (aktif ? Colors.greenAccent : Colors.grey.shade800),
                  foregroundColor: tamamlandi || !aktif ? Colors.white : Colors.black,
                  radius: 18,
                  child: tamamlandi 
                    ? const Icon(Icons.check, size: 20) 
                    : Text("${set.setNo}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: aktif 
                    ? _buildGirisAlani("Ağırlık", _agirlikController, isDecimal: true)
                    : Text(tamamlandi || !aktif ? "${set.agirlik} kg" : "-", style: TextStyle(color: tamamlandi ? Colors.white : Colors.grey.shade600, fontSize: 16), textAlign: TextAlign.center),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: aktif
                    ? _buildGirisAlani("Tekrar", _tekrarController, isDecimal: false)
                    : Text(tamamlandi || !aktif ? "${set.tekrar} Tekrar" : "-", style: TextStyle(color: tamamlandi ? Colors.white : Colors.grey.shade600, fontSize: 16), textAlign: TextAlign.center),
                ),
                if (aktif) ...[
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      final agirlik = double.tryParse(_agirlikController.text.replaceAll(',', '.')) ?? 0.0;
                      final tekrar = int.tryParse(_tekrarController.text) ?? 0;
                      context.read<AktifAntrenmanCubit>().setTamamla(agirlik, tekrar);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check, color: Colors.black),
                    ),
                  )
                ] else ...[
                  const SizedBox(width: 48),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGirisAlani(String hint, TextEditingController controller, {required bool isDecimal}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: Colors.black45,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}