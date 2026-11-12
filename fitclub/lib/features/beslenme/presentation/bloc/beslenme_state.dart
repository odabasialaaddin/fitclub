import 'package:equatable/equatable.dart';
import '../../data/models/besin_model.dart';

abstract class BeslenmeState extends Equatable {
  const BeslenmeState();

  @override
  List<Object> get props => [];
}

// 1. Sayfa ilk açıldığında boş ve arama yapılmamış durum
class BeslenmeInitial extends BeslenmeState {}

// 2. Arama butonuna basıldığında veriler internetten gelene kadar çalışan durum
class BeslenmeLoading extends BeslenmeState {}

// 3. Besinler başarıyla bulunduğunda listeyi arayüze taşıyan durum
class BeslenmeLoaded extends BeslenmeState {
  final List<BesinModel> besinler;

  const BeslenmeLoaded(this.besinler);

  @override
  List<Object> get props => [besinler];
}

// 4. Besin bulunamadığında veya internet koptuğunda çalışacak hata durumu
class BeslenmeError extends BeslenmeState {
  final String mesaj;

  const BeslenmeError(this.mesaj);

  @override
  List<Object> get props => [mesaj];
}