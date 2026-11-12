import 'package:equatable/equatable.dart';
import '../../data/models/egzersiz_model.dart';

// Ekranın girebileceği tüm durumların ana sınıfı
abstract class EgzersizState extends Equatable {
  const EgzersizState();

  @override
  List<Object> get props => [];
}

// 1. Uygulama ilk açıldığındaki boş durum
class EgzersizInitial extends EgzersizState {}

// 2. İnternetten veri çekilirkenki "Yükleniyor..." durumu
class EgzersizLoading extends EgzersizState {}

// 3. Veriler başarıyla geldiğinde çalışacak durum (İçinde egzersiz listesini taşır)
class EgzersizLoaded extends EgzersizState {
  final List<EgzersizModel> egzersizler;

  const EgzersizLoaded(this.egzersizler);

  @override
  // Equatable paketi sayesinde listeleri performanslı şekilde karşılaştırıyoruz
  List<Object> get props => [egzersizler]; 
}

// 4. İnternet koptuğunda veya sunucu çöktüğünde çalışacak hata durumu
class EgzersizError extends EgzersizState {
  final String mesaj;

  const EgzersizError(this.mesaj);

  @override
  List<Object> get props => [mesaj];
}