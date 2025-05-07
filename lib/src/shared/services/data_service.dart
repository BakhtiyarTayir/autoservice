import 'package:dio/dio.dart';
import 'package:autoservice/src/shared/models/brand_model.dart'; // Импортируем модель Brand

// Сервис для получения общих данных (бренды, модели и т.д.)
class DataService {
  final Dio _dio = Dio();
  // Базовый URL вашего API (тот же, что и в AuthService)
  final String _baseUrl = 'https://api.afix.uz'; // ЗАМЕНИТЬ НА ВАШ URL

  // Метод для получения списка брендов
  // Поддерживает пагинацию (необязательный параметр page)
  // Возвращает список Brand при успехе, иначе выбрасывает исключение
  Future<List<Brand>> getBrands({int? page}) async {
    try {
      // Формируем URL с параметром page, если он предоставлен
      String url = '$_baseUrl/brands'; // ЗАМЕНИТЕ '/brands' НА ВАШ РЕАЛЬНЫЙ ЭНДПОИНТ
      if (page != null) {
        url += '?page=$page';
      }

      print('Fetching brands from: $url'); // Логируем URL запроса

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        // Успешный ответ, парсим данные
        // Предполагаем, что API возвращает список объектов Brand
        // Если данные вложены (например, {'results': [...]}), измените парсинг:
        // final List<dynamic> brandListJson = response.data['results'] as List<dynamic>;
        final List<dynamic> brandListJson = response.data as List<dynamic>; // Предполагаем прямой список

        // Преобразуем каждый JSON-объект в объект Brand
        List<Brand> brands = brandListJson
            .map((json) => Brand.fromJson(json as Map<String, dynamic>))
            .toList();

        print('Fetched ${brands.length} brands.');
        return brands;
      } else {
        // Обработка других статусов или пустого ответа
        print('Failed to fetch brands. Status: ${response.statusCode}, Data: ${response.data}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch brands with status code ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      // Обработка ошибок Dio (сеть, таймауты, ошибки сервера)
      print('Dio error fetching brands: ${e.message}');
      print('Dio error response data: ${e.response?.data}');
      String errorMessage = 'Ошибка загрузки списка брендов.';
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionError) {
        errorMessage = 'Ошибка сети. Проверьте подключение к интернету.';
      } else if (e.response != null) {
         // Попытка извлечь сообщение об ошибке из ответа сервера
         try {
           final responseData = e.response?.data;
           if (responseData is Map && responseData.containsKey('detail')) {
             errorMessage = responseData['detail'].toString();
           } else if (responseData is Map && responseData.containsKey('message')) {
             errorMessage = responseData['message'].toString();
           }
         } catch (_) { /* Игнорируем ошибки парсинга ответа */ }
      }
      // Перебрасываем исключение с более понятным сообщением
      throw Exception(errorMessage);
    } on FormatException catch (e) {
       // Ошибка парсинга JSON в модели Brand
       print('Error parsing brand data: $e');
       throw Exception('Ошибка обработки данных брендов от сервера.');
    } catch (e) {
      // Обработка других неожиданных ошибок
      print('Unexpected error fetching brands: $e');
      throw Exception('Произошла непредвиденная ошибка при загрузке брендов.');
    }
  }

  // Сюда можно будет добавить другие методы для получения моделей, регионов и т.д.
  // Future<List<Model>> getModels({int? brandId}) async { ... }
  // Future<List<Region>> getRegions() async { ... }
  // ...
}