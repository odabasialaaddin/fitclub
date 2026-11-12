import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/beslenme_repository.dart';
import 'beslenme_state.dart';

class BeslenmeCubit extends Cubit<BeslenmeState> {
  final BeslenmeRepository _repository;

  // Sayfa açıldığında başlangıç (Initial) durumunu veriyoruz
  BeslenmeCubit(this._repository) : super(BeslenmeInitial());

  // Kullanıcı arama yaptığında tetiklenecek fonksiyon
  Future<void> besinAra(String sorgu) async {
    // Boş bir arama yapılırsa hiçbir şey yapmadan dön
    if (sorgu.trim().isEmpty) return; 

    // Ekranda yükleme çarkını çıkartıyoruz
    emit(BeslenmeLoading());
    
    try {
      // Repository'den verileri istiyoruz
      final liste = await _repository.besinAra(sorgu);
      
      if (liste.isEmpty) {
        // Eğer API bu ismi bulamazsa veya liste boş dönerse
        emit(const BeslenmeError("Aradığınız besin bulunamadı."));
      } else {
        // Veriler başarıyla geldiyse arayüze teslim ediyoruz
        emit(BeslenmeLoaded(liste));
      }
    } catch (e) {
      // Beklenmedik bir hata olursa
      emit(BeslenmeError("Bir hata oluştu: $e"));
    }
  }
}