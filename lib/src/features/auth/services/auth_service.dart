// Для jsonDecode
import 'package:dio/dio.dart';
import 'package:autoservice/src/features/auth/models/token_model.dart';
import 'package:autoservice/src/features/auth/models/user_model.dart';

// Сервис для взаимодействия с API аутентификации
class AuthService {
  final Dio _dio = Dio();
  // Базовый URL вашего API (замените на ваш реальный URL)
  // Пример: 'http://192.168.1.100:8000/api' или 'https://yourdomain.com/api'
  final String _baseUrl = 'https://api.afix.uz'; // ЗАМЕНИТЬ НА ВАШ URL

  // Метод для входа пользователя
  // Возвращает Token при успехе, иначе выбрасывает исключение
  Future<Token> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login', // Убедитесь, что эндпоинт верный
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Успешный вход, парсим токен
        // Предполагаем, что API возвращает JSON вида {'access_token': '...'}
        return Token.fromJson(response.data);
      } else {
        // Обработка других статусов или пустого ответа
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Login failed with status code ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      // Обработка ошибок Dio (сеть, таймауты, ошибки сервера)
      print('Dio error during login: ${e.message}');
      String errorMessage = 'Ошибка входа.';
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        errorMessage = 'Неверное имя пользователя или пароль.';
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка сети. Проверьте подключение к интернету.';
      }
      // Перебрасываем исключение с более понятным сообщением
      throw Exception(errorMessage);
    } catch (e) {
      // Обработка других неожиданных ошибок
      print('Unexpected error during login: $e');
      throw Exception('Произошла непредвиденная ошибка.');
    }
  }

  // Метод для регистрации нового пользователя
  // Возвращает User при успехе, иначе выбрасывает исключение
  Future<User> register({
    required String username,
    required String password,
    String? phone,
    String? firstName,
    // Добавьте другие необходимые поля для регистрации
  }) async {
    try {
      final requestData = {
        'username': username,
        'password': password,
        'phone': phone,
        'firstname': firstName,
      };
      print('Sending registration data: $requestData');

      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: requestData,
      );

      // Проверяем статус ответа
      if (response.statusCode == 201 && response.data != null) {
        // Успешная регистрация (статус 201), парсим данные пользователя (если API так возвращает)
        // Убедитесь, что User.fromJson может обработать ответ при 201
        // Возможно, здесь тоже нужно сначала получить токен, а потом данные пользователя?
        // Если при 201 возвращается токен, логика должна быть как в блоке для 200 ниже.
        // Если при 201 возвращаются данные пользователя, оставляем как есть:
        try {
          // Попытка парсинга как User, если API возвращает User при 201
           return User.fromJson(response.data as Map<String, dynamic>);
        } catch (e) {
           // Если при 201 приходит токен, обрабатываем как в блоке 200
           print('Registration (201) did not return User directly, attempting to fetch user details...');
           final tokenData = Token.fromJson(response.data as Map<String, dynamic>);
           return await _fetchUserDetails(tokenData.accessToken);
        }

      } else if (response.statusCode == 200 && response.data != null) {
        // Статус 200, анализируем тело ответа
        final responseData = response.data;
        // Проверяем, что это Map и содержит ключ 'success'
        if (responseData is Map<String, dynamic> && responseData.containsKey('success')) {
          if (responseData['success'] == true && responseData.containsKey('access_token')) {
            // Успешная регистрация: { "success": true, "access_token": "..." }
            print('Registration successful (200), received token. Fetching user details...');
            final tokenData = Token.fromJson(responseData); // Используем весь Map для парсинга Token
            // Получаем данные пользователя, используя токен
            return await _fetchUserDetails(tokenData.accessToken);
          } else if (responseData['success'] == false && responseData.containsKey('message')) {
            // Ошибка валидации или другая ошибка: { "success": false, "message": "..." }
            final errorMessage = responseData['message'].toString();
            print('Registration failed (200 - success: false): $errorMessage');
            throw Exception(errorMessage); // Выбрасываем ошибку с сообщением от API
          } else {
             // Неожиданный формат ответа при status 200
             print('Registration failed (200): Unexpected response format. Response: $responseData');
             throw Exception('Ошибка регистрации: Неожиданный ответ сервера.');
          }
        } else {
           // Ответ не содержит 'success' или не является Map
           print('Registration failed (200): Invalid response format. Response: $responseData');
           throw Exception('Ошибка регистрации: Неверный формат ответа сервера.');
        }
      } else {
        // Обработка других статусов или пустого ответа
        print('Registration failed with status code ${response.statusCode}. Response: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Registration failed with status code ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      // Обработка ошибок Dio
      print('Dio error during registration: $e');
      print('Dio error response data: ${e.response?.data}');
      print('Dio error type: ${e.type}');
      String errorMessage = 'Ошибка регистрации.';
      if (e.response?.statusCode == 400) {
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
             // Сначала проверяем на { "success": false, "message": "..." } при 400
             if (responseData.containsKey('success') && responseData['success'] == false && responseData.containsKey('message')) {
                 errorMessage = responseData['message'].toString();
             } else if (responseData.containsKey('detail')) { // Потом проверяем 'detail'
                 errorMessage = responseData['detail'].toString();
             } else if (responseData.containsKey('username')) { // Потом 'username'
                 errorMessage = 'Пользователь с таким именем уже существует.';
             } else {
                 // Если ничего не подошло, общее сообщение для 400
                 errorMessage = 'Ошибка валидации данных (400).';
             }
          } else {
             errorMessage = 'Ошибка обработки ответа сервера (400).';
          }
        } catch (_){ errorMessage = 'Ошибка обработки ответа сервера (400).'; }
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка сети. Проверьте подключение к интернету.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Обработка других неожиданных ошибок (включая ошибки парсинга)
      print('Unexpected error during registration: $e');
      // Добавляем проверку типа ошибки парсинга
      if (e is TypeError) {
         print('Type error details: ${e.stackTrace}');
         throw Exception('Ошибка обработки данных пользователя. Проверьте модель User.');
      }
      // Если ошибка парсинга Token
      if (e is FormatException && e.message.contains('Token.fromJson')) {
         print('Error parsing token data: $e');
         throw Exception('Ошибка обработки токена от сервера.');
      }
      throw Exception('Произошла непредвиденная ошибка при регистрации.');
    }
  }

  // Вспомогательный метод для получения данных пользователя по токену
  Future<User> _fetchUserDetails(String token) async {
    try {
      print('Fetching user details with token...');
      // ЗАМЕНИТЕ '/users/me' НА ВАШ РЕАЛЬНЫЙ ЭНДПОИНТ ДЛЯ ПОЛУЧЕНИЯ ДАННЫХ ПОЛЬЗОВАТЕЛЯ
      final response = await _dio.get(
        '$_baseUrl/users/me', // Пример эндпоинта
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        print('User details fetched successfully.');
        // Парсим данные пользователя
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        print('Failed to fetch user details. Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Не удалось получить данные пользователя после регистрации.');
      }
    } on DioException catch (e) {
       print('Dio error fetching user details: $e');
       print('Dio error response data: ${e.response?.data}');
       // Можно добавить более специфичную обработку ошибок (например, 401 - невалидный токен)
       throw Exception('Ошибка при получении данных пользователя: ${e.message}');
    } catch (e) {
       print('Unexpected error fetching user details: $e');
       if (e is TypeError) {
         print('Type error details: ${e.stackTrace}');
         throw Exception('Ошибка обработки данных пользователя. Проверьте модель User.');
       }
       throw Exception('Непредвиденная ошибка при получении данных пользователя.');
    }
  }

  // Метод для выхода пользователя (если требуется инвалидация токена на бэкенде)
  Future<void> logout(String token) async {
    try {
      // Пример: Отправка запроса на эндпоинт выхода
      // await _dio.post(
      //   '$_baseUrl/auth/logout',
      //   options: Options(headers: {'Authorization': 'Bearer $token'}),
      // );
      print('Logout request sent for token (simulated): $token');
      // В реальном приложении здесь будет запрос на сервер
      await Future.delayed(const Duration(milliseconds: 100)); // Имитация
    } on DioException catch (e) {
      // Ошибки при выходе обычно можно игнорировать или просто логировать
      print('Dio error during logout: ${e.message}');
    } catch (e) {
      print('Unexpected error during logout: $e');
    }
  }
}