import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/auth/services/auth_interceptor.dart'; 
import 'package:autoservice/src/features/auth/services/token_storage.dart';  


const String baseUrl = 'https://api.afix.uz'; // Убираем /api из URL


final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(); 
});

// Провайдер для Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.baseUrl = baseUrl;
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Настраиваем валидацию статусов, чтобы не выбрасывать исключения для статусов 404 и 401
  dio.options.validateStatus = (status) {
    return status != null && status >= 200 && status < 500; 
  };

  final tokenStorage = ref.watch(tokenStorageProvider);
  
  // Добавляем AuthInterceptor для автоматического добавления Bearer token
  dio.interceptors.add(AuthInterceptor(dio, tokenStorage));

  // Добавляем логгер для отладки HTTP запросов
  dio.interceptors.add(LogInterceptor(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: true,
    error: true,
    logPrint: (object) => print('DIO HTTP: $object'),
  ));

  return dio;
});