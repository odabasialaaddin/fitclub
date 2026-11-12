import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/antrenman_entity.dart';
import 'aktif_antrenman_state.dart';

class AktifAntrenmanCubit extends Cubit<AktifAntrenmanState> {
  Timer? _timer;

  AktifAntrenmanCubit() : super(AktifAntrenmanInitial());

  void antrenmanaBasla(AntrenmanRutini rutin) {
    final kopyalananHareketler = rutin.hareketler.map((h) =>
      AntrenmanHareketi(
        hareketId: h.hareketId,
        hareketAdi: h.hareketAdi,
        setler: h.setler.map((s) => AntrenmanSeti(setNo: s.setNo, agirlik: s.agirlik, tekrar: s.tekrar)).toList()
      )
    ).toList();

    final yeniRutin = AntrenmanRutini(
      id: rutin.id,
      rutinAdi: rutin.rutinAdi,
      hareketler: kopyalananHareketler,
    );

    emit(AktifAntrenmanDevamEdiyor(
      rutin: yeniRutin,
      aktifHareketIndex: 0,
      aktifSetIndex: 0,
      dinlenmeModu: false,
      kalanSure: 60,
    ));
  }

  void setTamamla(double agirlik, int tekrar) {
    if (state is! AktifAntrenmanDevamEdiyor) return;
    final currentState = state as AktifAntrenmanDevamEdiyor;

    final rutin = currentState.rutin;
    final hIndex = currentState.aktifHareketIndex;
    final sIndex = currentState.aktifSetIndex;

    rutin.hareketler[hIndex].setler[sIndex] = AntrenmanSeti(
      setNo: rutin.hareketler[hIndex].setler[sIndex].setNo,
      agirlik: agirlik,
      tekrar: tekrar,
    );

    bool sonHareketMi = hIndex == rutin.hareketler.length - 1;
    bool sonSetMi = sIndex == rutin.hareketler[hIndex].setler.length - 1;

    if (sonHareketMi && sonSetMi) {
      emit(currentState.copyWith(
        rutin: rutin,
        aktifSetIndex: sIndex + 1,
        tamamlandi: true,
      ));
    } else {
      emit(currentState.copyWith(rutin: rutin));
      _dinlenmeyiBaslat();
    }
  }

  void _dinlenmeyiBaslat() {
    if (state is! AktifAntrenmanDevamEdiyor) return;
    final currentState = state as AktifAntrenmanDevamEdiyor;

    emit(currentState.copyWith(dinlenmeModu: true, kalanSure: 60));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is! AktifAntrenmanDevamEdiyor) {
        timer.cancel();
        return;
      }
      final current = state as AktifAntrenmanDevamEdiyor;
      
      if (current.kalanSure > 0) {
        emit(current.copyWith(kalanSure: current.kalanSure - 1));
      } else {
        dinlenmeyiBitir();
      }
    });
  }

  void dinlenmeyiBitir() {
    _timer?.cancel();
    if (state is! AktifAntrenmanDevamEdiyor) return;
    final currentState = state as AktifAntrenmanDevamEdiyor;

    final rutin = currentState.rutin;
    int hIndex = currentState.aktifHareketIndex;
    int sIndex = currentState.aktifSetIndex;

    if (sIndex < rutin.hareketler[hIndex].setler.length - 1) {
      sIndex++;
    } else {
      hIndex++;
      sIndex = 0;
    }

    emit(currentState.copyWith(
      dinlenmeModu: false,
      aktifHareketIndex: hIndex,
      aktifSetIndex: sIndex,
    ));
  }

  void sureEkle(int saniye) {
    if (state is! AktifAntrenmanDevamEdiyor) return;
    final currentState = state as AktifAntrenmanDevamEdiyor;
    emit(currentState.copyWith(kalanSure: currentState.kalanSure + saniye));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}