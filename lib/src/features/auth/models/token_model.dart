// Модель данных для токена аутентификации
class TokenModel {
  final String accessToken;
  final String? refreshToken; // Может быть необязательным
  final DateTime? expiresAt; // Время истечения срока действия токена

  TokenModel({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  // Фабричный конструктор для создания из JSON (пример)
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'], // Убедитесь, что ключи соответствуют API
      refreshToken: json['refresh_token'],
      // Пример парсинга даты, если она приходит в виде строки ISO 8601
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
    );
  }

  // Метод для преобразования в JSON (если нужно отправлять данные)
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  // Геттер для проверки, истек ли токен
  bool get isExpired {
    if (expiresAt == null) {
      return false; // Если нет информации о сроке действия, считаем, что не истек
    }
    return DateTime.now().isAfter(expiresAt!);
  }
}