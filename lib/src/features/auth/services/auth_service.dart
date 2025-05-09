// Для jsonDecode
import 'package:dio/dio.dart';
import 'package:autoservice/src/features/auth/models/token_model.dart';
import 'package:autoservice/src/features/auth/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' show FlutterSecureStorage;

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
    final Map<String, dynamic> requestData = {
      'username': username,
      'password': password,
    };
    if (phone != null && phone.isNotEmpty) {
      requestData['phone'] = phone;
    }
    if (firstName != null && firstName.isNotEmpty) {
      // API ожидает 'firstname', а не 'firstName'
      requestData['firstname'] = firstName;
    }
    // Добавьте другие поля в requestData, если они есть

    print('Sending registration data: $requestData');

    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register', // Ваш эндпоинт регистрации
        data: requestData,
      );

      print('Registration response status: ${response.statusCode}');
      print('Registration response data: ${response.data}');

      // Проверяем статус ответа
      // API может вернуть 200 OK или 201 Created при успехе
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success') &&
            responseData['success'] == true &&
            responseData.containsKey('access_token')) {
          // Успешная регистрация, API вернул токен и данные пользователя

          // Важно: Убедитесь, что ваша модель User и ее конструктор User.fromJson
          // могут корректно обработать структуру responseData.
          // responseData теперь содержит: "access_token", "firstname", "phone", "username"
          // Если User.fromJson ожидает другую структуру (например, вложенный объект user),
          // вам может потребоваться создать объект User вручную здесь.
          // Пример:
          // final user = User(
          //   username: responseData['username'] as String,
          //   firstName: responseData['firstname'] as String?,
          //   phone: responseData['phone'] as String?,
          //   token: responseData['access_token'] as String, // Если токен хранится в User
          //   // id может быть null, если не возвращается
          // );
          // return user;

          // Попытка использовать User.fromJson, предполагая, что он адаптирован:
          try {
            print('Registration successful, parsing user data from registration response...');
            // Передаем весь responseData в User.fromJson
            // User.fromJson должен уметь извлечь 'access_token' и сохранить его,
            // а также остальные поля: 'firstname', 'phone', 'username'.
            final user = User.fromJson(responseData);

            // Если токен не является частью модели User, но его нужно сохранить отдельно:
            // First define FlutterSecureStorage at class level before using it
            final _secureStorage = FlutterSecureStorage();
            await _secureStorage.write(key: 'auth_token', value: responseData['access_token'] as String);
            print('User created from registration response: ${user.username}');
            return user;
          } catch (e) {
            print('Error parsing User from registration response: $e');
            print('Response data was: $responseData');
            throw Exception('Ошибка обработки данных пользователя после регистрации.');
          }

        } else if (responseData is Map<String, dynamic> &&
                   responseData.containsKey('success') &&
                   responseData['success'] == false &&
                   responseData.containsKey('message')) {
          // Ошибка валидации или другая ошибка от API с success: false
          final errorMessage = responseData['message'].toString();
          print('Registration failed (API success: false): $errorMessage');
          throw Exception(errorMessage);
        } else {
          // Неожиданный формат ответа
          print('Registration failed: Unexpected response format. Response: $responseData');
          throw Exception('Ошибка регистрации: Неожиданный ответ сервера.');
        }
      } else {
        // Обработка других статусов HTTP
        print('Registration failed with status code ${response.statusCode}. Response: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Registration failed with status code ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      // Обработка ошибок Dio (сеть, таймауты, ошибки сервера и т.д.)
      print('Dio error during registration: ${e.message}');
      print('Dio error response data: ${e.response?.data}');
      String errorMessage = 'Ошибка регистрации.';
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) { // 422 Unprocessable Entity часто для ошибок валидации
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('success') && responseData['success'] == false && responseData.containsKey('message')) {
              errorMessage = responseData['message'].toString();
            } else if (responseData.containsKey('detail')) {
              errorMessage = responseData['detail'].toString();
            } else if (responseData.containsKey('message')) { // Общий ключ message
              errorMessage = responseData['message'].toString();
            } else if (responseData.containsKey('username')) {
              errorMessage = 'Пользователь с таким именем уже существует или ошибка в поле username.';
            } else {
              // Попытка собрать ошибки валидации по полям, если они есть
              // Это зависит от формата ошибок валидации вашего API
              // Например, если ошибки приходят как {'field_name': ['error_message']}
              // StringBuffer errors = StringBuffer();
              // responseData.forEach((key, value) {
              //   if (value is List && value.isNotEmpty) {
              //     errors.writeln('$key: ${value.join(', ')}');
              //   } else if (value is String) {
              //      errors.writeln('$key: $value');
              //   }
              // });
              // if (errors.isNotEmpty) errorMessage = errors.toString();
              // else errorMessage = 'Ошибка валидации данных.';
              errorMessage = 'Ошибка валидации данных (код ${e.response?.statusCode}).';
            }
          } else {
            errorMessage = 'Ошибка обработки ответа сервера (код ${e.response?.statusCode}).';
          }
        } catch (_) {
          errorMessage = 'Ошибка обработки ответа сервера (код ${e.response?.statusCode}).';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.sendTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка сети. Проверьте подключение к интернету.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Обработка других неожиданных ошибок
      print('Unexpected error during registration: $e');
      if (e is TypeError) {
        print('Type error details: ${e.stackTrace}');
        throw Exception('Ошибка обработки данных. Проверьте типы данных.');
      }
      throw Exception('Произошла непредвиденная ошибка при регистрации.');
    }
  }

  // Метод _fetchUserDetails может все еще быть нужен для логина или обновления данных
  // Убедитесь, что эндпоинт для него корректен, если он существует
  Future<User> _fetchUserDetails(String token) async {
    try {
      print('Fetching user details with token...');
      // ЗАМЕНИТЕ '/auth/user' НА ПРАВИЛЬНЫЙ ЭНДПОИНТ ВАШЕГО API для получения данных пользователя
      const String userDetailsEndpoint = '/auth/user'; // Пример

      final response = await _dio.get(
        '$_baseUrl$userDetailsEndpoint',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        print('User details fetched successfully.');
        // Предполагается, что этот эндпоинт возвращает полную информацию о пользователе
        // и User.fromJson может ее обработать.
        // Также, если токен не является частью User, его нужно передать или добавить.
        Map<String, dynamic> userData = response.data as Map<String, dynamic>;
        // Если токен нужно добавить в User модель из этого ответа:
        // userData['access_token'] = token; // или как он там называется в User.fromJson
        return User.fromJson(userData);
      } else {
        print('Failed to fetch user details. Status: ${response.statusCode}, Data: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch user details with status code ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('Dio error fetching user details: ${e.message}');
      print('Dio error response data: ${e.response?.data}');
      String errorMessage = 'Ошибка при получении данных пользователя.';
       if (e.response?.statusCode == 401) {
        errorMessage = 'Сессия истекла или недействительна. Пожалуйста, войдите снова.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Эндпоинт для получения данных пользователя не найден.';
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка сети при получении данных пользователя.';
      }
      throw Exception(errorMessage);
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