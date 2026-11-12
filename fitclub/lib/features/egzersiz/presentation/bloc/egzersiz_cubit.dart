import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/egzersiz_repository.dart';
import '../../data/models/egzersiz_model.dart';
import 'egzersiz_state.dart';

class EgzersizCubit extends Cubit<EgzersizState> {
  final EgzersizRepository _repository;
  
  // ÇÖZÜM: İnternetten çektiğimiz 100 hareketi burada yedekliyoruz.
  // Böylece arama yaparken sürekli internetten veri çekip kotayı/şarjı bitirmeyeceğiz.
  List<EgzersizModel> _tumEgzersizler = []; 

  EgzersizCubit(this._repository) : super(EgzersizInitial());

  Future<void> egzersizleriGetir() async {
    emit(EgzersizLoading());
    try {
      final liste = await _repository.egzersizleriGetir();
      _tumEgzersizler = liste; // Gelen veriyi ana kasamıza yedekledik
      emit(EgzersizLoaded(liste));
    } catch (e) {
      emit(EgzersizError("Egzersizler yüklenirken bir hata oluştu."));
    }
  }

  // YENİ: Arama Motoru Fonksiyonu
  void egzersizAra(String arananKelime) {
    // Eğer kullanıcı arama çubuğunu temizlediyse orijinal listeyi geri ver
    if (arananKelime.isEmpty) {
      emit(EgzersizLoaded(_tumEgzersizler));
      return;
    }

    // Kullanıcının yazdığı kelimeyi küçük harfe çevirip ana listede arıyoruz
    final filtrelenmisListe = _tumEgzersizler.where((hareket) {
      return hareket.name.toLowerCase().contains(arananKelime.toLowerCase());
    }).toList();

    // Sadece eşleşenleri ekrana gönder
    emit(EgzersizLoaded(filtrelenmisListe));
  }
}