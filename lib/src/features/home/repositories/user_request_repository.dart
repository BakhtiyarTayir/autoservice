// lib/src/features/home/repositories/user_request_repository.dart

import 'package:dio/dio.dart'; // Для HTTP-запросов
import 'package:autoservice/src/features/requests/data/user_request_model.dart'; // Обновленная модель заявки пользователя
// import 'package:autoservice/src/core/network/dio_provider.dart'; // Если используется глобальный dioProvider

// TODO: Определите этот репозиторий на основе фактических требований API.
// Это предварительная структура.

class UserRequestRepository {
  final Dio _dio;
  // Базовый URL API может быть здесь или получен из конфигурации
  // final String _baseUrl = 'https://api.afix.uz/api/user_requests'; // Пример

  // Конструктор может принимать экземпляр Dio
  // Если вы используете Riverpod, вы можете получить Dio через ref.watch(dioProvider)
  UserRequestRepository(this._dio);

  // Метод для получения списка заявок пользователя (например, по ID пользователя)
  Future<List<UserRequest>> fetchUserRequests({
    required String userId, // Обязательный параметр для идентификации пользователя
    RequestStatus? status, // Фильтр по статусу
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'user_id': userId,
        'page': page,
        'limit': limit,
      };
      if (status != null) {
        queryParameters['status'] = status.toString().split('.').last;
      }

      // TODO: Замените '/user_requests' на актуальный эндпоинт вашего API
      final response = await _dio.get('/user_requests', queryParameters: queryParameters);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> responseData = response.data['data'] ?? response.data;
        if (responseData is List) {
          return responseData.map((json) => UserRequest.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Неверный формат данных от API: ожидался список заявок.');
        }
      } else {
        throw Exception('Ошибка при загрузке заявок пользователя: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException при загрузке заявок пользователя: ${e.message}');
      throw Exception('Сетевая ошибка при загрузке заявок: ${e.message}');
    } catch (e) {
      print('Неизвестная ошибка при загрузке заявок пользователя: ${e.toString()}');
      throw Exception('Не удалось загрузить список заявок пользователя.');
    }
  }

  // Метод для получения информации о конкретной заявке по ID
  Future<UserRequest> fetchUserRequestById(String requestId) async {
    try {
      // TODO: Замените '/user_requests/$requestId' на актуальный эндпоинт вашего API
      final response = await _dio.get('/user_requests/$requestId');

      if (response.statusCode == 200 && response.data != null) {
        return UserRequest.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Ошибка при загрузке заявки: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException при загрузке заявки $requestId: ${e.message}');
      throw Exception('Сетевая ошибка при загрузке заявки: ${e.message}');
    } catch (e) {
      print('Неизвестная ошибка при загрузке заявки $requestId: ${e.toString()}');
      throw Exception('Не удалось загрузить информацию о заявке.');
    }
  }

  // Метод для создания новой заявки
  Future<UserRequest> createUserRequest(UserRequest requestData) async {
    try {
      // TODO: Замените '/user_requests' на актуальный эндпоинт вашего API для POST запроса
      final response = await _dio.post('/user_requests', data: requestData.toJson());

      if (response.statusCode == 201 && response.data != null) { // Обычно 201 Created
        return UserRequest.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Ошибка при создании заявки: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException при создании заявки: ${e.message}');
      throw Exception('Сетевая ошибка при создании заявки: ${e.message}');
    } catch (e) {
      print('Неизвестная ошибка при создании заявки: ${e.toString()}');
      throw Exception('Не удалось создать заявку.');
    }
  }

  // Метод для обновления существующей заявки (например, отмена)
  Future<UserRequest> updateUserRequest(String requestId, Map<String, dynamic> updateData) async {
    try {
      // TODO: Замените '/user_requests/$requestId' на актуальный эндпоинт вашего API для PUT или PATCH запроса
      final response = await _dio.patch('/user_requests/$requestId', data: updateData);

      if (response.statusCode == 200 && response.data != null) {
        return UserRequest.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Ошибка при обновлении заявки: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException при обновлении заявки $requestId: ${e.message}');
      throw Exception('Сетевая ошибка при обновлении заявки: ${e.message}');
    } catch (e) {
      print('Неизвестная ошибка при обновлении заявки $requestId: ${e.toString()}');
      throw Exception('Не удалось обновить заявку.');
    }
  }

  // Другие методы, если нужны (например, добавление комментария к заявке и т.д.)
}

// Пример провайдера для Riverpod, если используется:
/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/core/network/dio_provider.dart'; // Провайдер Dio

final userRequestRepositoryProvider = Provider<UserRequestRepository>((ref) {
  final dio = ref.watch(dioProvider); // Получаем Dio из провайдера
  return UserRequestRepository(dio);
});
*/