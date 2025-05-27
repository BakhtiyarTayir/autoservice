// Для jsonDecode
import 'dart:convert'; // Для jsonDecode
import 'package:dio/dio.dart';
import 'package:autoservice/src/features/auth/models/token_model.dart';
import 'package:autoservice/src/features/auth/models/user_model.dart';
import 'package:autoservice/src/features/auth/services/token_storage.dart'; // Импорт TokenStorage
// import 'package:flutter_secure_storage/flutter_secure_storage.dart' show FlutterSecureStorage; // Больше не нужен напрямую

// Сервис для взаимодействия с API аутентификации
class AuthService {
  final Dio _dio = Dio();
  final TokenStorage _tokenStorage; // Внедряем TokenStorage
  // Базовый URL API 
  final String _baseUrl = 'https://api.afix.uz'; // ЗАМЕНИТЬ НА ВАШ URL

  // Конструктор с TokenStorage
  AuthService(this._tokenStorage);

  // Метод для входа пользователя
  // Возвращает User при успехе, иначе выбрасывает исключение
  Future<User> login(String username, String password) async {
    try {
      print('AuthService: Attempting login for user: $username');
      final response = await _dio.post(
        '$_baseUrl/auth/login', // Убедитесь, что эндпоинт верный
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Успешный вход, парсим токен
        print('AuthService: Login successful, response data: ${response.data}');
        final tokenModel = TokenModel.fromJson(response.data);
        await _tokenStorage.saveToken(tokenModel.accessToken);
        print('AuthService: Token saved: ${tokenModel.accessToken.substring(0, 15)}...');

        // Получаем данные пользователя, включая partnerId
        final user = await fetchUserDetailsOnLoad(tokenModel.accessToken);
        if (user.partnerId != null) {
          await _tokenStorage.savePartnerId(user.partnerId!);
          print('AuthService: Partner ID saved: ${user.partnerId}');
        }
        return user;
      } else {
        // Обработка других статусов или пустого ответа
        print('AuthService: Login failed, status code: ${response.statusCode}, data: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Login failed with status code ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      // Обработка ошибок Dio (сеть, таймауты, ошибки сервера)
      print('AuthService: Dio error during login: ${e.message}');
      print('AuthService: Response status: ${e.response?.statusCode}');
      print('AuthService: Response data: ${e.response?.data}');
      
      String errorMessage = 'Ошибка входа.';
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        errorMessage = 'Неверное имя пользователя или пароль.';
      } else if (e.type == DioExceptionType.connectionTimeout || 
                e.type == DioExceptionType.sendTimeout || 
                e.type == DioExceptionType.receiveTimeout || 
                e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка сети. Проверьте подключение к интернету.';
      }
      // Перебрасываем исключение с более понятным сообщением
      throw Exception(errorMessage);
    } catch (e) {
      // Обработка других неожиданных ошибок
      print('AuthService: Unexpected error during login: $e');
      throw Exception('Произошла непредвиденная ошибка при входе: $e');
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

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success') &&
            responseData['success'] == true &&
            responseData.containsKey('access_token')) {
          
          final String accessToken = responseData['access_token'] as String;
          await _tokenStorage.saveToken(accessToken);
          print('AuthService: Token saved after registration: $accessToken');

          // User.fromJson должен уметь извлечь 'partner_id' если он есть в responseData
          final user = User.fromJson(responseData); 
          print('User created from registration response: ${user.username}, Partner ID: ${user.partnerId}');

          if (user.partnerId != null) {
            await _tokenStorage.savePartnerId(user.partnerId!);
            print('AuthService: Partner ID saved after registration: ${user.partnerId}');
          }
          return user;

        } else if (responseData is Map<String, dynamic> &&
                   responseData.containsKey('success') &&
                   responseData['success'] == false &&
                   responseData.containsKey('message')) {
          final errorMessage = responseData['message'].toString();
          print('Registration failed (API success: false): $errorMessage');
          throw Exception(errorMessage);
        } else {
          print('Registration failed: Unexpected response format. Response: $responseData');
          throw Exception('Ошибка регистрации: Неожиданный ответ сервера.');
        }
      } else {
        print('Registration failed with status code ${response.statusCode}. Response: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Registration failed with status code ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('Dio error during registration: ${e.message}');
      print('Dio error response data: ${e.response?.data}');
      String errorMessage = 'Ошибка регистрации.';
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) { 
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('success') && responseData['success'] == false && responseData.containsKey('message')) {
              errorMessage = responseData['message'].toString();
            } else if (responseData.containsKey('detail')) {
              errorMessage = responseData['detail'].toString();
            } else if (responseData.containsKey('message')) { 
              errorMessage = responseData['message'].toString();
            } else if (responseData.containsKey('username')) {
              errorMessage = 'Пользователь с таким именем уже существует или ошибка в поле username.';
            } else {
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
      print('Unexpected error during registration: $e');
      if (e is TypeError) {
        print('Type error details: ${e.stackTrace}');
        throw Exception('Ошибка обработки данных. Проверьте типы данных.');
      }
      
      // Проверка на конкретное сообщение об ошибке "This user exist"
      if (e.toString().contains('This user exist')) {
        throw Exception('Пользователь с таким именем уже существует.');
      }
      
      throw Exception('Произошла непредвиденная ошибка при регистрации.');
    }
  }

  Future<User> fetchUserDetailsOnLoad(String token) async {
    try {
      print('AuthService: Fetching user details with token');
      const String userDetailsEndpoint = '/auth/user';

      final response = await _dio.get(
        '$_baseUrl$userDetailsEndpoint',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        print('AuthService: User details fetched successfully: ${response.data}');
        Map<String, dynamic> userData = response.data as Map<String, dynamic>;        
        return User.fromJson(userData);
      } else {
        print('AuthService: Failed to fetch user details. Status: ${response.statusCode}, Data: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch user details with status code ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('AuthService: Dio error fetching user details: ${e.message}');
      print('AuthService: Response status: ${e.response?.statusCode}');
      print('AuthService: Response data: ${e.response?.data}');
      
      String errorMessage = 'Ошибка при получении данных пользователя.';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Сессия истекла или недействительна. Пожалуйста, войдите снова.';
        // Здесь можно очистить токен, чтобы пользователь точно перешел на экран входа
        await _tokenStorage.deleteAll(); 
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Эндпоинт для получения данных пользователя не найден.';
      } else if (e.type == DioExceptionType.connectionTimeout || 
                e.type == DioExceptionType.sendTimeout || 
                e.type == DioExceptionType.receiveTimeout || 
                e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка сети при получении данных пользователя.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('AuthService: Unexpected error fetching user details: $e');
      if (e is TypeError) {
        print('AuthService: Type error details: ${e.stackTrace}');
        throw Exception('Ошибка обработки данных пользователя. Проверьте модель User.');
      }
      throw Exception('Непредвиденная ошибка при получении данных пользователя: $e');
    }
  }

  // Метод для выхода пользователя
  Future<void> logout() async {
    try {
      print('AuthService: Logging out user');
      // Очищаем токен
      await _tokenStorage.deleteAll();
      print('AuthService: All tokens and data cleared');
      
      // Если у API есть эндпоинт для логаута (чтобы инвалидировать токен на сервере)
      // то можно выполнить запрос к нему здесь, например:
      // 
      // final token = await _tokenStorage.getToken();
      // if (token != null) {
      //   try {
      //     await _dio.post(
      //       '$_baseUrl/auth/logout',
      //       options: Options(headers: {'Authorization': 'Bearer $token'}),
      //     );
      //   } catch (e) {
      //     print('Error during API logout: $e');
      //     // Игнорируем ошибку при логауте на сервере, т.к. локально мы все равно удалили токен
      //   }
      // }
    } catch (e) {
      print('AuthService: Error during logout: $e');
      // Перебрасываем ошибку, чтобы AuthNotifier мог обработать её
      throw Exception('Ошибка при выходе: $e');
    }
  }
}