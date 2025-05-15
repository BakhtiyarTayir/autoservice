// lib/src/features/home/repositories/partner_repository.dart

import 'package:autoservice/src/features/partner/data/partner_model.dart';
import 'package:dio/dio.dart'; // Для HTTP-запросов


class PartnerRepository {
  final Dio _dio;
  // Базовый URL API может быть здесь или получен из конфигурации
  // final String _baseUrl = 'https://api.afix.uz/api/partners'; // Пример

  // Конструктор может принимать экземпляр Dio
  // Если вы используете Riverpod, вы можете получить Dio через ref.watch(dioProvider)
  PartnerRepository(this._dio);

  // Метод для получения списка партнеров
  Future<List<Partner>> fetchPartners({
    String? searchTerm,
    String? serviceType,
    // Другие параметры фильтрации или пагинации
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Формируем параметры запроса
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParameters['search'] = searchTerm;
      }
      if (serviceType != null && serviceType.isNotEmpty) {
        queryParameters['service_type'] = serviceType;
      }

      // TODO: Замените '/partners' на актуальный эндпоинт вашего API
      final response = await _dio.get('/partners', queryParameters: queryParameters);

      if (response.statusCode == 200 && response.data != null) {
        // Предполагаем, что API возвращает список объектов партнеров
        // или объект с полем, содержащим список (например, 'data' или 'items')
        final List<dynamic> responseData = response.data['data'] ?? response.data;
        if (responseData is List) {
          return responseData.map((json) => Partner.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Неверный формат данных от API: ожидался список партнеров.');
        }
      } else {
        // Обработка ошибок сервера
        throw Exception('Ошибка при загрузке партнеров: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Обработка ошибок Dio (сеть, таймауты и т.д.)
      // Можно добавить более детальное логирование или обработку e.response
      print('DioException при загрузке партнеров: ${e.message}');
      throw Exception('Сетевая ошибка при загрузке партнеров: ${e.message}');
    } catch (e) {
      // Обработка других ошибок
      print('Неизвестная ошибка при загрузке партнеров: ${e.toString()}');
      throw Exception('Не удалось загрузить список партнеров.');
    }
  }

  // Метод для получения информации о конкретном партнере по ID
  Future<Partner> fetchPartnerById(String partnerId) async {
    try {
      // TODO: Замените '/partners/$partnerId' на актуальный эндпоинт вашего API
      final response = await _dio.get('/partners/$partnerId');

      if (response.statusCode == 200 && response.data != null) {
        return Partner.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Ошибка при загрузке партнера: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException при загрузке партнера $partnerId: ${e.message}');
      throw Exception('Сетевая ошибка при загрузке партнера: ${e.message}');
    } catch (e) {
      print('Неизвестная ошибка при загрузке партнера $partnerId: ${e.toString()}');
      throw Exception('Не удалось загрузить информацию о партнере.');
    }
  }

  // Другие методы, если нужны (например, добавление отзыва, получение услуг партнера и т.д.)
}

// Пример провайдера для Riverpod, если используется:
/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/core/network/dio_provider.dart'; // Провайдер Dio

final partnerRepositoryProvider = Provider<PartnerRepository>((ref) {
  final dio = ref.watch(dioProvider); // Получаем Dio из провайдера
  return PartnerRepository(dio);
});
*/