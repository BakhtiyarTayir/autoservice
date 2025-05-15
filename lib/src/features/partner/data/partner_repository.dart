import 'package:dio/dio.dart';
import 'package:autoservice/src/features/partner/data/partner_model.dart';
// TODO: Импортировать или настроить общий HTTP-клиент (Dio) с baseUrl и интерцептором токена

class PartnerRepository {
  final Dio _dio; // Dio инстанс будет предоставлен с уже настроенным baseUrl

  PartnerRepository(this._dio);

  /// Получает детали о партнере.
  ///
  /// Эндпоинт `GET {{base_url}}/partners/{partnerId}`.
  Future<Partner> getPartnerDetails(String partnerId) async {
    try {
      print('Requesting partner details with URL: ${_dio.options.baseUrl}/partners/$partnerId');
      final response = await _dio.get('/partners/$partnerId');

      if (response.statusCode == 200 && response.data != null) {
        return Partner.fromJson(response.data as Map<String, dynamic>);
      } else {
        // Если не сработал прямой путь, попробуем альтернативный эндпоинт
        print('Trying alternative endpoint: ${_dio.options.baseUrl}/partners/edit/$partnerId');
        final alternativeResponse = await _dio.get('/partners/edit/$partnerId');
        
        if (alternativeResponse.statusCode == 200 && alternativeResponse.data != null) {
          return Partner.fromJson(alternativeResponse.data as Map<String, dynamic>);
        } else {
          throw Exception('Failed to load partner details for ID $partnerId, status codes: ${response.statusCode}, ${alternativeResponse.statusCode}');
        }
      }
    } on DioException catch (e) {
      print('DioException in getPartnerDetails for ID $partnerId: ${e.message}');
      print('Request URL: ${e.requestOptions.path}');
      print('Response status: ${e.response?.statusCode}');
      throw Exception('Failed to load partner details for ID $partnerId: ${e.message}');
    } catch (e) {
      print('Error in getPartnerDetails for ID $partnerId: ${e.toString()}');
      throw Exception('An unexpected error occurred while fetching partner details for ID $partnerId.');
    }
  }

  /// Получает список всех партнеров.
  /// Эндпоинт `GET {{base_url}}/partners`.
  Future<List<Partner>> getAllPartners() async {
    try {
      print('Requesting all partners with URL: ${_dio.options.baseUrl}/partners');
      final response = await _dio.get('/partners');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> partnerListJson = response.data as List<dynamic>;
        print('Partners data: $partnerListJson');
        return partnerListJson.map((json) => Partner.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load all partners, status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in getAllPartners: ${e.message}');
      print('Request URL: ${e.requestOptions.path}');
      print('Response status: ${e.response?.statusCode}');
      throw Exception('Failed to load all partners: ${e.message}');
    } catch (e) {
      print('Error in getAllPartners: ${e.toString()}');
      throw Exception('An unexpected error occurred while fetching all partners.');
    }
  }
}