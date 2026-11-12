import 'package:equatable/equatable.dart';
import '../../domain/entities/antrenman_entity.dart';

abstract class AktifAntrenmanState extends Equatable {
  const AktifAntrenmanState();

  @override
  List<Object?> get props => [];
}

class AktifAntrenmanInitial extends AktifAntrenmanState {}

class AktifAntrenmanDevamEdiyor extends AktifAntrenmanState {
  final AntrenmanRutini rutin;
  final int aktifHareketIndex;
  final int aktifSetIndex;
  final bool dinlenmeModu;
  final int kalanSure;
  final bool tamamlandi;

  const AktifAntrenmanDevamEdiyor({
    required this.rutin,
    required this.aktifHareketIndex,
    required this.aktifSetIndex,
    required this.dinlenmeModu,
    required this.kalanSure,
    this.tamamlandi = false,
  });

  // State'i tamamen yeniden üretmek yerine sadece değişen kısımları güncellemek için copyWith kullanıyoruz
  AktifAntrenmanDevamEdiyor copyWith({
    AntrenmanRutini? rutin,
    int? aktifHareketIndex,
    int? aktifSetIndex,
    bool? dinlenmeModu,
    int? kalanSure,
    bool? tamamlandi,
  }) {
    return AktifAntrenmanDevamEdiyor(
      rutin: rutin ?? this.rutin,
      aktifHareketIndex: aktifHareketIndex ?? this.aktifHareketIndex,
      aktifSetIndex: aktifSetIndex ?? this.aktifSetIndex,
      dinlenmeModu: dinlenmeModu ?? this.dinlenmeModu,
      kalanSure: kalanSure ?? this.kalanSure,
      tamamlandi: tamamlandi ?? this.tamamlandi,
    );
  }

  @override
  List<Object?> get props => [
        rutin,
        aktifHareketIndex,
        aktifSetIndex,
        dinlenmeModu,
        kalanSure,
        tamamlandi,
      ];
}