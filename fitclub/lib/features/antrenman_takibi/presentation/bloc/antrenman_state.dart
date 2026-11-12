import 'package:equatable/equatable.dart';
import '../../domain/entities/antrenman_entity.dart';

abstract class AntrenmanState extends Equatable {
  const AntrenmanState();

  @override
  List<Object> get props => [];
}

class AntrenmanInitial extends AntrenmanState {}

class AntrenmanLoading extends AntrenmanState {}

// İki farklı yüklendi durumu yerine, her iki veriyi de aynı anda tutan tek bir State kullanıyoruz.
class AntrenmanLoaded extends AntrenmanState {
  final List<AntrenmanKaydi> gecmisKayitlar;
  final List<AntrenmanRutini> rutinler;

  const AntrenmanLoaded({
    this.gecmisKayitlar = const [],
    this.rutinler = const [],
  });

  // State içindeki verilerden sadece birini güncellemek için copyWith metodunu kullanıyoruz
  AntrenmanLoaded copyWith({
    List<AntrenmanKaydi>? gecmisKayitlar,
    List<AntrenmanRutini>? rutinler,
  }) {
    return AntrenmanLoaded(
      gecmisKayitlar: gecmisKayitlar ?? this.gecmisKayitlar,
      rutinler: rutinler ?? this.rutinler,
    );
  }

  @override
  List<Object> get props => [gecmisKayitlar, rutinler];
}

class AntrenmanError extends AntrenmanState {
  final String mesaj;

  const AntrenmanError(this.mesaj);

  @override
  List<Object> get props => [mesaj];
}