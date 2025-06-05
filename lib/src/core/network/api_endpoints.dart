// Файл с централизованным хранением всех эндпоинтов API

/// Базовый URL API
class ApiBaseUrl {
  static const String value = 'https://api.afix.uz'; // Базовый URL API, который используется во всех сервисах
}

/// Эндпоинты для аутентификации
class AuthEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout'; // Закомментирован в коде, но может понадобиться
  static const String userDetails = '/auth/user'; // Не используется, но упоминается в коде
  
  /// Получить полный URL для эндпоинта аутентификации
  static String getFullUrl(String endpoint) {
    return ApiBaseUrl.value + endpoint;
  }
}

/// Эндпоинты для партнеров (автосервисов)
class PartnersEndpoints {
  static const String list = '/partners';
  static const String details = '/partners/'; // + partnerId
  static const String edit = '/partners/edit/'; // + partnerId
  static const String create = '/partners';
  
  /// Получить полный URL для деталей партнера
  static String getDetailsUrl(String partnerId) {
    return details + partnerId;
  }
  
  /// Получить полный URL для редактирования партнера
  static String getEditUrl(String partnerId) {
    return edit + partnerId;
  }
  
  /// Получить полный URL для эндпоинта партнеров
  static String getFullUrl(String endpoint) {
    return ApiBaseUrl.value + endpoint;
  }
}

/// Эндпоинты для запросов пользователей
class UserRequestsEndpoints {
  // Эндпоинты в директории requests
  static const String partnerRequests = '/user-requests/partner/'; // + partnerId
  static const String userRequestsByUserId = '/user-requests/user/'; // + userId
  static const String currentUserRequests = '/user-requests/user';
  
  // Эндпоинты в директории home (альтернативные пути)
  static const String list = '/user_requests';
  static const String details = '/user_requests/'; // + requestId
  static const String create = '/user_requests';
  static const String update = '/user_requests/'; // + requestId
  
  /// Получить полный URL для запросов партнера
  static String getPartnerRequestsUrl(String partnerId) {
    return partnerRequests + partnerId;
  }
  
  /// Получить полный URL для запросов пользователя по ID
  static String getUserRequestsByUserIdUrl(String userId) {
    return userRequestsByUserId + userId;
  }
  
  /// Получить полный URL для деталей запроса
  static String getDetailsUrl(String requestId) {
    return details + requestId;
  }
  
  /// Получить полный URL для обновления запроса
  static String getUpdateUrl(String requestId) {
    return update + requestId;
  }
  
  /// Получить полный URL для эндпоинта запросов пользователей
  static String getFullUrl(String endpoint) {
    return ApiBaseUrl.value + endpoint;
  }
}

/// Эндпоинты для общих данных
class DataEndpoints {
  static const String brands = '/brands';
  // Можно добавить другие эндпоинты для моделей, регионов и т.д.
  
  /// Получить полный URL для эндпоинта данных
  static String getFullUrl(String endpoint) {
    return ApiBaseUrl.value + endpoint;
  }
}

/// Класс для удобного доступа ко всем эндпоинтам
class ApiEndpoints {
  /// Получить полный URL для эндпоинта
  static String getFullUrl(String endpoint) {
    return ApiBaseUrl.value + endpoint;
  }
}