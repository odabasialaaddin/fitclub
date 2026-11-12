import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  // İnternet isteklerini yapacağımız temel Dio objemiz
  late final Dio dio;

  // Sınıf çağrıldığında çalışacak ilk kurulum (Constructor)
  DioClient() {
    dio = Dio(
      BaseOptions(
        // İnternet yavaşsa uygulamanın sonsuza kadar donmasını engellemek için zaman sınırları (10 saniye)
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor: Ağ isteği internete çıkmadan saniyeler önce araya giren "Güvenlik Görevlisi"
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Eğer atılan istek Wger API'ye gidiyorsa...
          if (options.uri.toString().contains('wger.de')) {
            // Gizli .env dosyamızdan API anahtarımızı okuyoruz
            final wgerKey = dotenv.env['WGER_API_KEY'];
            
            if (wgerKey != null && wgerKey.isNotEmpty) {
              // Wger API'nin kurallarına göre anahtarı Header (Başlık) kısmına ekliyoruz
              options.headers['Authorization'] = 'Token $wgerKey';
            }
          }
          // Anahtarı ekledikten sonra isteğin hedefine gitmesine izin ver
          return handler.next(options); 
        },
        onError: (DioException e, handler) {
          // Bir hata olursa konsola yazdırıyoruz ki geliştirirken hatayı kolayca bulalım
          print("🚨 API Hatası [${e.response?.statusCode}]: ${e.requestOptions.path}");
          return handler.next(e);
        },
      ),
    );
  }
}