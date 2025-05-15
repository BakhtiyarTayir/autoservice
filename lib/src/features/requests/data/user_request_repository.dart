import 'package:dio/dio.dart';
import 'package:autoservice/src/features/requests/data/user_request_model.dart';


class UserRequestRepository {
  final Dio _dio;

  UserRequestRepository(this._dio);

  /// Получает список заявок для конкретного партнера.
  ///
  /// Эндпоинт: `GET {{base_url}}/user-requests/partner/{partner_id}`
  Future<List<UserRequest>> getPartnerRequests(String partnerId) async {
    try {
      print('Requesting partner requests with URL: ${_dio.options.baseUrl}/user-requests/partner/$partnerId');
      final response = await _dio.get('/user-requests/partner/$partnerId');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> requestsList = response.data as List<dynamic>;
        return requestsList
            .map((requestJson) => UserRequest.fromJson(requestJson as Map<String, dynamic>))
            .toList();
      } else {
        // Детальное сообщение об ошибке с кодом статуса
        throw Exception('Failed to load user requests for partner $partnerId. Status code: ${response.statusCode}, Response: ${response.data}');
      }
    } on DioException catch (e) {
      // Обработка ошибок Dio с более подробной информацией
      print('DioException in getPartnerRequests: ${e.message}');
      print('Request URL: ${e.requestOptions.path}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      
      String errorMessage = 'Failed to load user requests';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed: Please log in again to refresh your session';
      } else if (e.response?.statusCode == 403) {
        errorMessage = 'You do not have permission to view these requests';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'No requests found for partner $partnerId';
      } else if (e.type == DioExceptionType.connectionTimeout || 
                e.type == DioExceptionType.receiveTimeout || 
                e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Network timeout, please check your connection';
      }
      
      throw Exception('$errorMessage (${e.response?.statusCode ?? "unknown status"})');
    } catch (e) {
      print('Error in getPartnerRequests: $e');
      throw Exception('An unexpected error occurred while fetching user requests: $e');
    }
  }

  /// Получает список заявок для конкретного пользователя.
  ///
  /// Эндпоинт: `GET {{base_url}}/user-requests/user/{user_id}`
  Future<List<UserRequest>> getUserRequestsByUserId(String userId) async {
    try {
      print('Requesting user requests with URL: ${_dio.options.baseUrl}/user-requests/user/$userId');
      final response = await _dio.get('/user-requests/user/$userId');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> requestsList = response.data as List<dynamic>;
        return requestsList
            .map((requestJson) => UserRequest.fromJson(requestJson as Map<String, dynamic>))
            .toList();
      } else {
        // Детальное сообщение об ошибке с кодом статуса
        throw Exception('Failed to load user requests for user $userId. Status code: ${response.statusCode}, Response: ${response.data}');
      }
    } on DioException catch (e) {
      print('DioException in getUserRequestsByUserId for user $userId: ${e.message}');
      print('Request URL: ${e.requestOptions.path}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      
      String errorMessage = 'Failed to load user requests';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed: Please log in again to refresh your session';
      } else if (e.response?.statusCode == 403) {
        errorMessage = 'You do not have permission to view these requests';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'No requests found for user $userId';
      } else if (e.type == DioExceptionType.connectionTimeout || 
                e.type == DioExceptionType.receiveTimeout || 
                e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Network timeout, please check your connection';
      }
      
      throw Exception('$errorMessage (${e.response?.statusCode ?? "unknown status"})');
    } catch (e) {
      print('Error in getUserRequestsByUserId for user $userId: $e');
      throw Exception('An unexpected error occurred while fetching user requests for user $userId: $e');
    }
  }
  
  /// Получает список заявок текущего пользователя.
  ///
  /// Эндпоинт: `GET {{base_url}}/user-requests/user`
  Future<List<UserRequest>> getCurrentUserRequests() async {
    try {
      print('Requesting current user requests with URL: ${_dio.options.baseUrl}/user-requests/user');
      final response = await _dio.get('/user-requests/user');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> requestsList = response.data as List<dynamic>;
        return requestsList
            .map((requestJson) => UserRequest.fromJsonV2(requestJson as Map<String, dynamic>))
            .toList();
      } else {
        // Детальное сообщение об ошибке с кодом статуса
        throw Exception('Failed to load current user requests. Status code: ${response.statusCode}, Response: ${response.data}');
      }
    } on DioException catch (e) {
      print('DioException in getCurrentUserRequests: ${e.message}');
      print('Request URL: ${e.requestOptions.path}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      
      String errorMessage = 'Failed to load user requests';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed: Please log in again to refresh your session';
      } else if (e.response?.statusCode == 403) {
        errorMessage = 'You do not have permission to view these requests';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'No requests found';
      } else if (e.type == DioExceptionType.connectionTimeout || 
                e.type == DioExceptionType.receiveTimeout || 
                e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Network timeout, please check your connection';
      }
      
      throw Exception('$errorMessage (${e.response?.statusCode ?? "unknown status"})');
    } catch (e) {
      print('Error in getCurrentUserRequests: $e');
      throw Exception('An unexpected error occurred while fetching current user requests: $e');
    }
  }
}