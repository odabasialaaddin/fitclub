import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/antrenman_entity.dart';
import '../../domain/usecases/antrenman_usecases.dart';
import 'antrenman_state.dart';

class AntrenmanCubit extends Cubit<AntrenmanState> {
  final AntrenmanKaydetUseCase _kaydetUseCase;
  final TumGecmisKayitlariGetirUseCase _tumGecmisUseCase;
  final HareketeGoreGecmisGetirUseCase _hareketeGoreGecmisUseCase;
  final AntrenmanSilUseCase _silUseCase;
  
  final RutinKaydetUseCase _rutinKaydetUseCase;
  final TumRutinleriGetirUseCase _tumRutinleriGetirUseCase;
  final RutinSilUseCase _rutinSilUseCase;

  final List<AntrenmanHareketi> _aktifSepet = [];

  List<AntrenmanHareketi> get aktifSepet => _aktifSepet;

  AntrenmanCubit({
    required AntrenmanKaydetUseCase kaydetUseCase,
    required TumGecmisKayitlariGetirUseCase tumGecmisUseCase,
    required HareketeGoreGecmisGetirUseCase hareketeGoreGecmisUseCase,
    required AntrenmanSilUseCase silUseCase,
    required RutinKaydetUseCase rutinKaydetUseCase,
    required TumRutinleriGetirUseCase tumRutinleriGetirUseCase,
    required RutinSilUseCase rutinSilUseCase,
  })  : _kaydetUseCase = kaydetUseCase,
        _tumGecmisUseCase = tumGecmisUseCase,
        _hareketeGoreGecmisUseCase = hareketeGoreGecmisUseCase,
        _silUseCase = silUseCase,
        _rutinKaydetUseCase = rutinKaydetUseCase,
        _tumRutinleriGetirUseCase = tumRutinleriGetirUseCase,
        _rutinSilUseCase = rutinSilUseCase,
        super(AntrenmanInitial());

  // Mevcut verileri kaybetmemek için yardımcı getter
  AntrenmanLoaded get _mevcutDurum {
    if (state is AntrenmanLoaded) {
      return state as AntrenmanLoaded;
    }
    return const AntrenmanLoaded();
  }

  void sepeteHareketEkle(AntrenmanHareketi hareket) {
    _aktifSepet.add(hareket);
  }

  void sepetiTemizle() {
    _aktifSepet.clear();
  }

  Future<void> aktifAntrenmaniKaydet() async {
    if (_aktifSepet.isEmpty) return;

    try {
      final mevcutVeriler = _mevcutDurum;
      emit(AntrenmanLoading());
      
      final yeniKayit = AntrenmanKaydi(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tarih: DateTime.now(),
        hareketler: List.from(_aktifSepet),
      );

      await _kaydetUseCase.call(yeniKayit); 
      _aktifSepet.clear();
      
      // Kayıttan sonra geçmişi güncelle ama rutinleri silme
      final guncelKayitlar = await _tumGecmisUseCase.call();
      emit(mevcutVeriler.copyWith(gecmisKayitlar: guncelKayitlar));
    } catch (e) {
      emit(AntrenmanError("Antrenman kaydedilemedi: $e"));
    }
  }

  Future<void> gecmisKayitlariGetir() async {
    try {
      final mevcutVeriler = _mevcutDurum;
      emit(AntrenmanLoading()); 
      final kayitlar = await _tumGecmisUseCase.call(); 
      emit(mevcutVeriler.copyWith(gecmisKayitlar: kayitlar)); 
    } catch (e) {
      emit(AntrenmanError("Geçmiş kayıtlar alınırken bir hata oluştu: $e"));
    }
  }

  Future<void> hareketeGoreGecmisGetir(String hareketId) async {
    try {
      final mevcutVeriler = _mevcutDurum;
      emit(AntrenmanLoading());
      final kayitlar = await _hareketeGoreGecmisUseCase.call(hareketId);
      emit(mevcutVeriler.copyWith(gecmisKayitlar: kayitlar));
    } catch (e) {
      emit(AntrenmanError("Hareket geçmişi alınırken bir hata oluştu: $e"));
    }
  }

  Future<void> antrenmaniSil(String id) async {
    try {
      final mevcutVeriler = _mevcutDurum;
      emit(AntrenmanLoading()); 
      await _silUseCase.call(id); 
      final guncelKayitlar = await _tumGecmisUseCase.call();
      emit(mevcutVeriler.copyWith(gecmisKayitlar: guncelKayitlar));
    } catch (e) {
      emit(AntrenmanError("Antrenman silinirken hata oluştu: $e"));
    }
  }

  Future<void> rutinleriGetir() async {
    try {
      final mevcutVeriler = _mevcutDurum;
      emit(AntrenmanLoading());
      final rutinler = await _tumRutinleriGetirUseCase.call();
      emit(mevcutVeriler.copyWith(rutinler: rutinler));
    } catch (e) {
      emit(AntrenmanError("Rutinler alınırken bir hata oluştu: $e"));
    }
  }

  Future<void> rutinKaydet(AntrenmanRutini rutin) async {
    try {
      final mevcutVeriler = _mevcutDurum;
      emit(AntrenmanLoading());
      await _rutinKaydetUseCase.call(rutin);
      final guncelRutinler = await _tumRutinleriGetirUseCase.call();
      emit(mevcutVeriler.copyWith(rutinler: guncelRutinler));
    } catch (e) {
      emit(AntrenmanError("Rutin kaydedilemedi: $e"));
    }
  }

  Future<void> rutinSil(String id) async {
    try {
      final mevcutVeriler = _mevcutDurum;
      emit(AntrenmanLoading());
      await _rutinSilUseCase.call(id);
      final guncelRutinler = await _tumRutinleriGetirUseCase.call();
      emit(mevcutVeriler.copyWith(rutinler: guncelRutinler));
    } catch (e) {
      emit(AntrenmanError("Rutin silinirken hata oluştu: $e"));
    }
  }
}