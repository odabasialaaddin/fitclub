import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:hive_flutter/hive_flutter.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart'; 

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

import 'features/egzersiz/data/repositories/egzersiz_repository.dart';
import 'features/egzersiz/presentation/bloc/egzersiz_cubit.dart';

import 'features/beslenme/data/repositories/beslenme_repository.dart';
import 'features/beslenme/presentation/bloc/beslenme_cubit.dart';
import 'features/beslenme/presentation/bloc/gunluk_beslenme_cubit.dart';

import 'features/antrenman_takibi/data/datasources/antrenman_local_data_source.dart';
import 'features/antrenman_takibi/data/repositories/antrenman_repository_impl.dart';
import 'features/antrenman_takibi/domain/usecases/antrenman_usecases.dart';
import 'features/antrenman_takibi/presentation/bloc/antrenman_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EgzersizCubit(EgzersizRepository()),
        ),
        BlocProvider(
          create: (context) => BeslenmeCubit(BeslenmeRepository()),
        ),
        BlocProvider(
          create: (context) => GunlukBeslenmeCubit(),
        ),
        BlocProvider(
          create: (context) {
            final localDataSource = AntrenmanLocalDataSourceImpl();
            final repository = AntrenmanRepositoryImpl(localDataSource);
            
            return AntrenmanCubit(
              kaydetUseCase: AntrenmanKaydetUseCase(repository),
              tumGecmisUseCase: TumGecmisKayitlariGetirUseCase(repository),
              hareketeGoreGecmisUseCase: HareketeGoreGecmisGetirUseCase(repository),
              silUseCase: AntrenmanSilUseCase(repository),
              rutinKaydetUseCase: RutinKaydetUseCase(repository),
              tumRutinleriGetirUseCase: TumRutinleriGetirUseCase(repository),
              rutinSilUseCase: RutinSilUseCase(repository),
            );
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Gelişmiş Fitness',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}